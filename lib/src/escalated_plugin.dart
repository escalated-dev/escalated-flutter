import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'escalated_config.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'services/api_client.dart';
import 'services/auth_hooks.dart';

/// An [InheritedWidget] that provides [EscalatedConfig] to the widget tree.
///
/// Wrap your app (or the portion that uses Escalated screens) with this widget.
/// It provides the configuration down the tree and sets up Riverpod overrides
/// for the auth hooks and API client.
///
/// ```dart
/// EscalatedPlugin(
///   config: EscalatedConfig(
///     apiBaseUrl: 'https://example.com/support/api/v1',
///   ),
///   child: MaterialApp.router(
///     routerConfig: yourRouter,
///   ),
/// )
/// ```
class EscalatedPlugin extends StatelessWidget {
  /// The Escalated library configuration.
  final EscalatedConfig config;

  /// The child widget tree.
  final Widget child;

  const EscalatedPlugin({
    super.key,
    required this.config,
    required this.child,
  });

  /// Retrieve the [EscalatedConfig] from the nearest ancestor [EscalatedPlugin].
  ///
  /// Returns null if no [EscalatedPlugin] is found in the widget tree.
  static EscalatedConfig? maybeOf(BuildContext context) {
    final widget =
        context.dependOnInheritedWidgetOfExactType<_EscalatedInherited>();
    return widget?.config;
  }

  /// Retrieve the [EscalatedConfig] from the nearest ancestor [EscalatedPlugin].
  ///
  /// Throws if no [EscalatedPlugin] is found in the widget tree.
  static EscalatedConfig of(BuildContext context) {
    final config = maybeOf(context);
    assert(config != null,
        'No EscalatedPlugin found in widget tree. Wrap your app with EscalatedPlugin.');
    return config!;
  }

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        authHooksProvider.overrideWithValue(config.authHooks),
        apiClientProvider.overrideWith((ref) {
          final hooks = ref.watch(authHooksProvider);
          return ApiClient(
            authHooks: hooks,
            baseUrl: config.apiBaseUrl,
          );
        }),
        themeProvider.overrideWith((ref) {
          return ThemeNotifier(
            primaryColor: config.primaryColor,
            borderRadius: config.borderRadius,
          );
        }),
      ],
      child: _EscalatedInherited(
        config: config,
        child: child,
      ),
    );
  }
}

class _EscalatedInherited extends InheritedWidget {
  final EscalatedConfig config;

  const _EscalatedInherited({
    required this.config,
    required super.child,
  });

  @override
  bool updateShouldNotify(_EscalatedInherited oldWidget) {
    return config.apiBaseUrl != oldWidget.config.apiBaseUrl ||
        config.darkMode != oldWidget.config.darkMode ||
        config.defaultLocale != oldWidget.config.defaultLocale ||
        config.primaryColor != oldWidget.config.primaryColor;
  }
}
