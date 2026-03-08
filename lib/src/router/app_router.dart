import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/guest/guest_create_screen.dart';
import '../screens/guest/guest_ticket_screen.dart';
import '../screens/kb/kb_article_screen.dart';
import '../screens/kb/kb_list_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/tickets/create_ticket_screen.dart';
import '../screens/tickets/ticket_detail_screen.dart';
import '../screens/tickets/ticket_list_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _ticketsNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'tickets');
final _kbNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'kb');
final _settingsNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'settings');

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/tickets',
    debugLogDiagnostics: false,
    redirect: (context, state) {
      final isAuth = authState.status == AuthStatus.authenticated;
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';
      final isGuestRoute = state.matchedLocation.startsWith('/guest');
      final isKbRoute = state.matchedLocation.startsWith('/kb');

      if (authState.status == AuthStatus.unknown) {
        return null;
      }

      if (!isAuth && !isAuthRoute && !isGuestRoute && !isKbRoute) {
        return '/login';
      }

      if (isAuth && isAuthRoute) {
        return '/tickets';
      }

      return null;
    },
    routes: [
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
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNavBar(navigationShell: navigationShell);
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
});

class ScaffoldWithNavBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const ScaffoldWithNavBar({
    super.key,
    required this.navigationShell,
  });

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
