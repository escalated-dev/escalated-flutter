import 'package:escalated/escalated.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../support/fake_server.dart';

const _verificationId = '0d9b6a1e-5f3c-4b8e-9a1d-2c4e6f8a0b1c';

Widget _app(FakeServer server, GuestAccessStore store, String initialLocation) {
  final router = GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: '/guest/create',
        builder: (context, state) => const GuestCreateScreen(),
      ),
      GoRoute(
        path: '/guest/lookup',
        builder: (context, state) => GuestLookupScreen(
          initialReference: state.uri.queryParameters['reference'],
        ),
      ),
      GoRoute(
        path: '/guest/:reference',
        builder: (context, state) =>
            GuestTicketScreen(reference: state.pathParameters['reference']!),
      ),
      GoRoute(path: '/login', builder: (context, state) => const Text('login')),
    ],
  );

  return ProviderScope(
    overrides: [
      apiServiceProvider.overrideWithValue(fakeApi(server)),
      guestAccessStoreProvider.overrideWithValue(store),
    ],
    child: MaterialApp.router(
      routerConfig: router,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    ),
  );
}

void main() {
  late FakeServer server;
  late InMemoryGuestAccessStore store;

  setUp(() {
    server = FakeServer()
      ..reply(
        'GET',
        '$apiPrefix/departments',
        const FakeResponse(200, {'data': []}),
      )
      ..reply(
        'POST',
        '$apiPrefix/guest/verification',
        const FakeResponse(202, {
          'verification_id': _verificationId,
          'expires_in': 600,
          'message': 'Check your email for a verification code.',
        }),
      );
    store = InMemoryGuestAccessStore();
  });

  Future<void> scrollTap(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  testWidgets('create: emails a code, then submits with it and opens the '
      'ticket', (tester) async {
    server
      ..reply(
        'POST',
        '$apiPrefix/guest/tickets',
        FakeResponse(201, {
          'data': guestTicketJson(
            token: 'new-grant',
            expiresAt: '2099-01-01T00:00:00+00:00',
          ),
        }),
      )
      ..reply(
        'GET',
        '$apiPrefix/guest/tickets/new-grant',
        FakeResponse(200, {'data': guestTicketJson()}),
      );

    await tester.pumpWidget(_app(server, store, '/guest/create'));
    await tester.pumpAndSettle();

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Ada Guest');
    await tester.enterText(fields.at(1), 'ada@example.com');
    await tester.enterText(fields.at(2), 'Parcel never arrived');
    await tester.enterText(fields.at(3), 'Tracking stopped on Monday.');

    await scrollTap(tester, find.byKey(const ValueKey('guest-create-submit')));

    expect(server.requests.last.path, '$apiPrefix/guest/verification');
    expect(server.requests.last.body['purpose'], 'ticket');
    expect(find.textContaining('We sent a code to ada@example.com'), findsOne);

    await tester.enterText(
      find.byKey(const ValueKey('guest-verification-code')),
      '12345678',
    );
    await scrollTap(tester, find.byKey(const ValueKey('guest-create-submit')));

    final create = server.requests.firstWhere(
      (r) => r.path == '$apiPrefix/guest/tickets',
    );
    expect(create.body['verification_id'], _verificationId);
    expect(create.body['verification_code'], '12345678');

    // Moved to the ticket by reference, with the grant stored for it.
    expect((await store.read('ESC-00042'))!.token, 'new-grant');
    expect(find.text('Parcel never arrived'), findsOneWidget);
    expect(server.requests.last.path, '$apiPrefix/guest/tickets/new-grant');
  });

  testWidgets('create: shows the wait after a 429', (tester) async {
    server.reply(
      'POST',
      '$apiPrefix/guest/verification',
      const FakeResponse(
        429,
        {'message': 'Please wait before requesting another code.'},
        {
          'retry-after': ['30'],
        },
      ),
    );

    await tester.pumpWidget(_app(server, store, '/guest/create'));
    await tester.pumpAndSettle();

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Ada Guest');
    await tester.enterText(fields.at(1), 'ada@example.com');
    await tester.enterText(fields.at(2), 'Subject');
    await tester.enterText(fields.at(3), 'Body');
    await scrollTap(tester, find.byKey(const ValueKey('guest-create-submit')));

    expect(
      find.text('Too many attempts. Try again in 30 seconds.'),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('guest-verification-code')), findsNothing);
  });

  testWidgets('ticket: an old link with no grant asks to verify again', (
    tester,
  ) async {
    await tester.pumpWidget(_app(server, store, '/guest/${'a' * 64}'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Your access to this ticket has ended. '
        'Verify your email to open it again.',
      ),
      findsOneWidget,
    );
    expect(server.requests.where((r) => r.path.contains('/tickets/')), isEmpty);
  });

  testWidgets('ticket: a refused grant leads to lookup, which renews it', (
    tester,
  ) async {
    await store.write(
      GuestAccessGrant(
        reference: 'ESC-00042',
        token: 'stale-grant',
        expiresAt: DateTime.utc(2099),
        email: 'ada@example.com',
      ),
    );
    server
      ..reply(
        'GET',
        '$apiPrefix/guest/tickets/stale-grant',
        const FakeResponse(404, {'message': 'Not Found'}),
      )
      ..reply(
        'POST',
        '$apiPrefix/guest/lookup',
        const FakeResponse(200, {
          'data': [
            {
              'reference': 'ESC-00042',
              'subject': 'Parcel never arrived',
              'guest_access_token': 'fresh-grant',
              'expires_at': '2099-01-01T00:00:00+00:00',
            },
          ],
        }),
      )
      ..reply(
        'GET',
        '$apiPrefix/guest/tickets/fresh-grant',
        FakeResponse(200, {'data': guestTicketJson()}),
      );

    await tester.pumpWidget(_app(server, store, '/guest/ESC-00042'));
    await tester.pumpAndSettle();

    expect(await store.read('ESC-00042'), isNull);
    await scrollTap(tester, find.byKey(const ValueKey('guest-verify-again')));

    // The lookup form keeps the reference.
    expect(
      tester
          .widget<TextFormField>(
            find.byKey(const ValueKey('guest-lookup-reference')),
          )
          .controller!
          .text,
      'ESC-00042',
    );
    await tester.enterText(
      find.byKey(const ValueKey('guest-lookup-email')),
      'ada@example.com',
    );
    await scrollTap(tester, find.byKey(const ValueKey('guest-lookup-submit')));
    expect(server.requests.last.body['purpose'], 'lookup');

    await tester.enterText(
      find.byKey(const ValueKey('guest-verification-code')),
      '87654321',
    );
    await scrollTap(tester, find.byKey(const ValueKey('guest-lookup-submit')));

    final lookup = server.requests.firstWhere(
      (r) => r.path == '$apiPrefix/guest/lookup',
    );
    expect(lookup.body['reference'], 'ESC-00042');
    expect(lookup.body['verification_code'], '87654321');

    expect((await store.read('ESC-00042'))!.token, 'fresh-grant');
    expect(find.text('Parcel never arrived'), findsOneWidget);
  });
}
