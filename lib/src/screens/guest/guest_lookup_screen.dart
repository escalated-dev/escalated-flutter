import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/app_localizations.dart';
import '../../models/guest_access.dart';
import '../../providers/guest_provider.dart';
import '../../services/guest_access_errors.dart';
import 'guest_messages.dart';

/// Finds a guest's tickets by reference and verified email, and gets fresh
/// access to them.
///
/// This is how a guest gets back in after their access ends, after
/// reinstalling, or when they arrive with a link from before verified access
/// (those carried a permanent token that servers no longer accept).
class GuestLookupScreen extends ConsumerStatefulWidget {
  /// Prefills the reference field.
  final String? initialReference;

  /// Called with the chosen ticket. Defaults to `context.go('/guest/{ref}')`.
  final void Function(BuildContext context, GuestAccessGrant grant)? onOpen;

  const GuestLookupScreen({super.key, this.initialReference, this.onOpen});

  @override
  ConsumerState<GuestLookupScreen> createState() => _GuestLookupScreenState();
}

class _GuestLookupScreenState extends ConsumerState<GuestLookupScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _referenceController;
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  GuestVerificationChallenge? _challenge;
  List<GuestAccessGrant>? _results;
  String? _codeError;
  String? _error;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _referenceController = TextEditingController(
      text: widget.initialReference ?? '',
    );
    _emailController.addListener(_onEmailChanged);
  }

  @override
  void dispose() {
    _referenceController.dispose();
    _emailController.dispose();
    _codeController.dispose();
    super.dispose();
  }

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

  Future<void> _requestCode() async {
    setState(() {
      _busy = true;
      _error = null;
      _codeError = null;
      _results = null;
    });
    try {
      final challenge = await ref
          .read(guestAccessServiceProvider)
          .requestCode(
            email: _emailController.text.trim(),
            purpose: GuestVerificationPurpose.lookup,
          );
      if (!mounted) return;
      setState(() {
        _challenge = challenge;
        _codeController.clear();
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = guestErrorText(
            AppLocalizations.of(context),
            e,
            'failed_to_send_code',
          );
        });
      }
    } finally {
      if (mounted) setState(() => _busy = false);
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
      _busy = true;
      _error = null;
      _codeError = null;
    });
    try {
      final grants = await ref
          .read(guestAccessServiceProvider)
          .lookup(
            challenge: challenge,
            code: _codeController.text,
            reference: _referenceController.text,
          );
      if (!mounted) return;
      // The code is spent either way.
      setState(() {
        _challenge = null;
        _codeController.clear();
        _results = grants;
      });
      if (grants.length == 1) _open(grants.single);
    } on GuestVerificationFailedException catch (e) {
      if (mounted) {
        setState(
          () => _codeError = AppLocalizations.of(context).t(e.messageKey),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = guestErrorText(
            AppLocalizations.of(context),
            e,
            'unexpected_error',
          );
        });
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _open(GuestAccessGrant grant) {
    final onOpen = widget.onOpen;
    if (onOpen != null) {
      onOpen(context, grant);
    } else {
      context.go('/guest/${Uri.encodeComponent(grant.reference)}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final results = _results;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.t('find_ticket'))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.t('find_ticket_hint'),
                style: TextStyle(fontSize: 14, color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const ValueKey('guest-lookup-reference'),
                controller: _referenceController,
                decoration: InputDecoration(
                  labelText: l10n.t('reference'),
                  prefixIcon: const Icon(Icons.tag),
                ),
                autocorrect: false,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.tf('field_required', {
                      'field': l10n.t('reference'),
                    });
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const ValueKey('guest-lookup-email'),
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: l10n.t('your_email'),
                  prefixIcon: const Icon(Icons.email_outlined),
                ),
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || !looksLikeEmail(value.trim())) {
                    return l10n.t('invalid_email');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              if (_challenge != null) ...[
                GuestCodeNotice(
                  email: _challenge!.email,
                  busy: _busy,
                  onResend: _requestCode,
                ),
                GuestCodeField(
                  controller: _codeController,
                  errorText: _codeError,
                  onSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: 16),
              ],
              if (_error != null) ...[
                Text(_error!, style: TextStyle(color: scheme.error)),
                const SizedBox(height: 16),
              ],
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  key: const ValueKey('guest-lookup-submit'),
                  onPressed: _busy ? null : _submit,
                  child: _busy
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          _challenge == null
                              ? l10n.t('send_code')
                              : l10n.t('verify'),
                        ),
                ),
              ),
              if (results != null) ...[
                const SizedBox(height: 24),
                if (results.isEmpty)
                  Text(
                    l10n.t('no_matching_tickets'),
                    style: TextStyle(color: scheme.onSurfaceVariant),
                  )
                else
                  for (final grant in results)
                    Card(
                      child: ListTile(
                        title: Text(grant.subject ?? grant.reference),
                        subtitle: Text(grant.reference),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _open(grant),
                      ),
                    ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
