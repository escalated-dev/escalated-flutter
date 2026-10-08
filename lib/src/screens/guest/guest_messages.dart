import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/guest_provider.dart';
import '../../services/guest_access_errors.dart';

/// The text to show for a failed guest request.
String guestErrorText(AppLocalizations l10n, Object error, String fallbackKey) {
  if (error is GuestRateLimitedException) {
    return rateLimitText(l10n, error.retryAfter);
  }
  return l10n.t(guestErrorKey(error, fallbackKey));
}

/// "Too many attempts", with the wait when the server gave one.
String rateLimitText(AppLocalizations l10n, Duration? retryAfter) {
  if (retryAfter == null) return l10n.t('guest_rate_limited_later');
  final seconds = retryAfter.inSeconds < 1 ? 1 : retryAfter.inSeconds;
  return l10n.tf('guest_rate_limited', {'seconds': seconds});
}

/// The code field shared by the create and lookup screens.
class GuestCodeField extends StatelessWidget {
  const GuestCodeField({
    super.key,
    required this.controller,
    this.errorText,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String? errorText;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return TextFormField(
      key: const ValueKey('guest-verification-code'),
      controller: controller,
      decoration: InputDecoration(
        labelText: l10n.t('verification_code'),
        prefixIcon: const Icon(Icons.password_outlined),
        errorText: errorText,
        errorMaxLines: 3,
      ),
      keyboardType: TextInputType.number,
      autocorrect: false,
      enableSuggestions: false,
      autofillHints: const [AutofillHints.oneTimeCode],
      textInputAction: TextInputAction.done,
      onFieldSubmitted: onSubmitted,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return l10n.tf('field_required', {
            'field': l10n.t('verification_code'),
          });
        }
        return null;
      },
    );
  }
}

/// A short notice that a code is on its way, with a resend action.
class GuestCodeNotice extends StatelessWidget {
  const GuestCodeNotice({
    super.key,
    required this.email,
    required this.onResend,
    this.busy = false,
  });

  final String email;
  final VoidCallback onResend;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.tf('verification_sent', {'email': email}),
          style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: busy ? null : onResend,
            child: Text(l10n.t('resend_code')),
          ),
        ),
      ],
    );
  }
}

bool looksLikeEmail(String value) {
  final at = value.indexOf('@');
  return at > 0 && at < value.length - 1 && !value.contains(' ');
}
