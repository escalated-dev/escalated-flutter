import 'package:escalated/escalated.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Example app demonstrating how to integrate the Escalated Flutter library.
///
/// This shows how a host app:
/// 1. Wraps with [EscalatedPlugin] and provides config
/// 2. Wires Escalated screens into its own GoRouter
/// 3. Uses the library's theme and localization support
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    EscalatedPlugin(
      config: EscalatedConfig(
        apiBaseUrl: 'https://example.com/support/api/v1',
        // Optionally provide a custom AuthHooks implementation:
        // authHooks: MyCustomAuthHooks(),
      ),
      child: const ExampleApp(),
    ),
  );
}

/// The root navigator key, used to push full-screen routes above the shell.
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _ticketsNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'tickets');
final _kbNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'kb');
final _settingsNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'settings');

/// Example GoRouter configuration wiring Escalated screens.
final _router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/tickets',
  debugLogDiagnostics: false,
  routes: [
    // Auth routes (full screen, no bottom nav)
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/guest/create',
      builder: (context, state) => const GuestCreateScreen(),
    ),
    GoRoute(
      path: '/guest/:reference',
      builder: (context, state) => GuestTicketScreen(
        reference: state.pathParameters['reference']!,
      ),
    ),

    // Main shell with bottom navigation
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return _ScaffoldWithNavBar(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          navigatorKey: _ticketsNavigatorKey,
          routes: [
            GoRoute(
              path: '/tickets',
              builder: (context, state) => const TicketListScreen(),
              routes: [
                GoRoute(
                  path: 'create',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) => const CreateTicketScreen(),
                ),
                GoRoute(
                  path: ':reference',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) => TicketDetailScreen(
                    reference: state.pathParameters['reference']!,
                  ),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _kbNavigatorKey,
          routes: [
            GoRoute(
              path: '/kb',
              builder: (context, state) => const KbListScreen(),
              routes: [
                GoRoute(
                  path: ':slug',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) => KbArticleScreen(
                    slug: state.pathParameters['slug']!,
                  ),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _settingsNavigatorKey,
          routes: [
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);

class ExampleApp extends ConsumerWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'Escalated Example',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeState.themeMode,
      locale: themeState.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: _router,
    );
  }
}

/// Simple scaffold with bottom navigation bar for the example app.
class _ScaffoldWithNavBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const _ScaffoldWithNavBar({required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.confirmation_number_outlined),
            activeIcon: Icon(Icons.confirmation_number),
            label: 'Tickets',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_outlined),
            activeIcon: Icon(Icons.menu_book),
            label: 'Knowledge Base',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
