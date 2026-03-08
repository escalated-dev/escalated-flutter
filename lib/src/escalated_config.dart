import 'package:flutter/material.dart';
import 'services/auth_hooks.dart';

/// Configuration for the Escalated support library.
///
/// Consumers create an instance of this class and pass it to [EscalatedPlugin]
/// to configure the library's behavior, theming, and authentication.
class EscalatedConfig {
  /// The base URL for the Escalated API (e.g. 'https://example.com/support/api/v1').
  final String apiBaseUrl;

  /// The authentication hooks implementation.
  /// Defaults to [DefaultAuthHooks] which uses Bearer token + FlutterSecureStorage.
  final AuthHooks authHooks;

  /// The default locale for the UI. Defaults to English.
  final Locale defaultLocale;

  /// Whether to start in dark mode. Defaults to false (light mode / system).
  final bool darkMode;

  /// Optional primary color override for theming.
  final Color? primaryColor;

  /// Optional border radius override for UI elements.
  final double? borderRadius;

  /// Creates a new [EscalatedConfig].
  ///
  /// [apiBaseUrl] is required. All other parameters have sensible defaults.
  EscalatedConfig({
    required this.apiBaseUrl,
    AuthHooks? authHooks,
    this.defaultLocale = const Locale('en'),
    this.darkMode = false,
    this.primaryColor,
    this.borderRadius,
  }) : authHooks = authHooks ?? DefaultAuthHooks();
}
