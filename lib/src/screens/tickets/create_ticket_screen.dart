import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/app_localizations.dart';
import '../../models/department.dart';
import '../../providers/auth_provider.dart';
import '../../theme/colors.dart';
import '../../widgets/file_dropzone.dart';

class CreateTicketScreen extends ConsumerStatefulWidget {
  const CreateTicketScreen({super.key});

  @override
  ConsumerState<CreateTicketScreen> createState() => _CreateTicketScreenState();
}

class _CreateTicketScreenState extends ConsumerState<CreateTicketScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();
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
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _descriptionController.dispose();
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final api = ref.read(apiServiceProvider);
      final ticket = await api.createTicket(
        subject: _subjectController.text.trim(),
        description: _descriptionController.text.trim(),
        priority: _selectedPriority,
        departmentId: _selectedDepartmentId,
        attachmentPaths:
            _files.isNotEmpty ? _files.map((f) => f.path).toList() : null,
      );

      if (mounted) {
        context.go('/tickets/${ticket.reference}');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create ticket. Please try again.'),
            backgroundColor: AppColors.statusEscalated,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.t('new_ticket')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
                value: _selectedPriority,
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
                  value: _selectedDepartmentId,
                  decoration: InputDecoration(
                    labelText: l10n.t('department'),
                    prefixIcon: const Icon(Icons.business_outlined),
                  ),
                  items: [
                    DropdownMenuItem<int?>(
                      value: null,
                      child: Text(
                        'None',
                        style: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
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
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(l10n.t('create_ticket')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
