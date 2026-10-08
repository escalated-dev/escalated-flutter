import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/app_localizations.dart';
import '../../models/department.dart';
import '../../models/guest_access.dart';
import '../../providers/auth_provider.dart';
import '../../providers/guest_provider.dart';
import '../../services/guest_access_errors.dart';
import '../../theme/colors.dart';
import '../../widgets/file_dropzone.dart';
import 'guest_messages.dart';

/// Guest ticket submission with email verification.
///
/// The first submit emails a code to the guest; the second sends the ticket
/// with that code. The new ticket's access grant is stored per ticket, and
/// the screen moves to `/guest/{reference}`.

class GuestCreateScreen extends ConsumerStatefulWidget {
  const GuestCreateScreen({super.key});

  @override
  ConsumerState<GuestCreateScreen> createState() => _GuestCreateScreenState();
}

class _GuestCreateScreenState extends ConsumerState<GuestCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _codeController = TextEditingController();
  GuestVerificationChallenge? _challenge;
  String? _codeError;
  bool _isRequestingCode = false;
  String _selectedPriority = 'medium';
  int? _selectedDepartmentId;
  List<SelectedFile> _files = [];
  List<Department> _departments = [];
  bool _isSubmitting = false;
  bool _loadingDepartments = true;

  static const _priorities = ['low', 'medium', 'high', 'urgent', 'critical'];

  @override
  void initState() {
    super.initState();
    _loadDepartments();
    _emailController.addListener(_onEmailChanged);
  }

  // A code is bound to the address it was sent to.
  void _onEmailChanged() {
    final challenge = _challenge;
    if (challenge != null && _emailController.text.trim() != challenge.email) {
      setState(() {
        _challenge = null;
        _codeError = null;
        _codeController.clear();
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _subjectController.dispose();
    _descriptionController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _loadDepartments() async {
    try {
      final api = ref.read(apiServiceProvider);
      final departments = await api.getDepartments();
      if (mounted) {
        setState(() {
          _departments = departments;
          _loadingDepartments = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _loadingDepartments = false);
      }
    }
  }

  Future<void> _requestCode() async {
    setState(() {
      _isRequestingCode = true;
      _codeError = null;
    });
    try {
      final challenge = await ref
          .read(guestAccessServiceProvider)
          .requestCode(
            email: _emailController.text.trim(),
            purpose: GuestVerificationPurpose.ticket,
          );
      if (!mounted) return;
      setState(() {
        _challenge = challenge;
        _codeController.clear();
      });
    } catch (e) {
      if (mounted) _showError(e, 'failed_to_send_code');
    } finally {
      if (mounted) setState(() => _isRequestingCode = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final challenge = _challenge;
    if (challenge == null || challenge.isExpired) {
      await _requestCode();
      return;
    }

    setState(() {
      _isSubmitting = true;
      _codeError = null;
    });

    try {
      final ticket = await ref
          .read(guestAccessServiceProvider)
          .createTicket(
            challenge: challenge,
            code: _codeController.text,
            name: _nameController.text.trim(),
            subject: _subjectController.text.trim(),
            description: _descriptionController.text.trim(),
            priority: _selectedPriority,
            departmentId: _selectedDepartmentId,
            attachmentPaths: _files.isNotEmpty
                ? _files.map((f) => f.path).toList()
                : null,
          );

      if (mounted) {
        context.go('/guest/${Uri.encodeComponent(ticket.reference)}');
      }
    } on GuestVerificationFailedException catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _codeError = AppLocalizations.of(context).t(e.messageKey);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        _showError(e, 'failed_to_create_ticket');
      }
    }
  }

  void _showError(Object error, String fallbackKey) {
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(guestErrorText(l10n, error, fallbackKey)),
        backgroundColor: AppColors.statusEscalated,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.t('submit_ticket')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/login'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: l10n.t('your_name'),
                  prefixIcon: const Icon(Icons.person_outline),
                ),
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '${l10n.t('name')} is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: l10n.t('your_email'),
                  prefixIcon: const Icon(Icons.email_outlined),
                ),
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '${l10n.t('email')} is required';
                  }
                  if (!looksLikeEmail(value.trim())) {
                    return l10n.t('invalid_email');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _subjectController,
                decoration: InputDecoration(
                  labelText: l10n.t('subject'),
                  prefixIcon: const Icon(Icons.title),
                ),
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '${l10n.t('subject')} is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: l10n.t('description'),
                  alignLabelWithHint: true,
                ),
                maxLines: 6,
                minLines: 4,
                textInputAction: TextInputAction.newline,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '${l10n.t('description')} is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedPriority,
                decoration: InputDecoration(
                  labelText: l10n.t('priority'),
                  prefixIcon: const Icon(Icons.flag_outlined),
                ),
                items: _priorities.map((priority) {
                  return DropdownMenuItem(
                    value: priority,
                    child: Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: AppColors.priorityColor(priority),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(l10n.t(priority)),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedPriority = value);
                  }
                },
              ),
              const SizedBox(height: 16),
              if (_loadingDepartments)
                const LinearProgressIndicator()
              else if (_departments.isNotEmpty)
                DropdownButtonFormField<int?>(
                  initialValue: _selectedDepartmentId,
                  decoration: InputDecoration(
                    labelText: l10n.t('department'),
                    prefixIcon: const Icon(Icons.business_outlined),
                  ),
                  items: [
                    DropdownMenuItem<int?>(
                      value: null,
                      child: Text(
                        'None',
                        style: TextStyle(color: scheme.onSurfaceVariant),
                      ),
                    ),
                    ..._departments.map((dept) {
                      return DropdownMenuItem<int?>(
                        value: dept.id,
                        child: Text(dept.name),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedDepartmentId = value);
                  },
                ),
              const SizedBox(height: 20),
              Text(
                l10n.t('attachments'),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              FileDropzone(
                files: _files,
                onFilesChanged: (files) => setState(() => _files = files),
              ),
              const SizedBox(height: 24),
              if (_challenge == null)
                Text(
                  l10n.t('verification_explainer'),
                  style: TextStyle(
                    fontSize: 13,
                    color: scheme.onSurfaceVariant,
                  ),
                )
              else ...[
                GuestCodeNotice(
                  email: _challenge!.email,
                  busy: _isRequestingCode || _isSubmitting,
                  onResend: _requestCode,
                ),
                GuestCodeField(
                  controller: _codeController,
                  errorText: _codeError,
                  onSubmitted: (_) => _submit(),
                ),
              ],
              const SizedBox(height: 16),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  key: const ValueKey('guest-create-submit'),
                  onPressed: _isSubmitting || _isRequestingCode
                      ? null
                      : _submit,
                  child: _isSubmitting || _isRequestingCode
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          _challenge == null
                              ? l10n.t('submit_ticket')
                              : l10n.t('verify_and_submit'),
                        ),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => context.go('/guest/lookup'),
                child: Text(l10n.t('find_ticket')),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    l10n.t('already_have_account'),
                    style: TextStyle(color: scheme.onSurfaceVariant),
                  ),
                ],
              ),
              TextButton(
                onPressed: () => context.go('/login'),
                child: Text(l10n.t('sign_in')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
