import 'package:dio/dio.dart';
import 'package:escalated/escalated.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Answers getTickets with [result], or throws [error].
class _FakeApi implements ApiService {
  _FakeApi({this.result, this.error});

  final PaginatedResponse<TicketSummary>? result;
  final Object? error;

  @override
  Future<PaginatedResponse<TicketSummary>> getTickets({
    int page = 1,
    String? search,
    String? status,
    String? priority,
  }) async {
    if (error != null) throw error!;
    return result!;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// A host brand: teal, as a seeded Material 3 scheme would give it.
final _hostTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0D9488)),
);

Widget _app(ApiService api, {Locale locale = const Locale('en')}) {
  return ProviderScope(
    overrides: [apiServiceProvider.overrideWithValue(api)],
    child: MaterialApp(
      theme: _hostTheme,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const TicketListScreen(),
    ),
  );
}

PaginatedResponse<TicketSummary> _page(List<TicketSummary> tickets) =>
    PaginatedResponse(
      data: tickets,
      currentPage: 1,
      lastPage: 1,
      perPage: 20,
      total: tickets.length,
    );

final _ticket = TicketSummary(
  id: 1,
  reference: 'ESC-00042',
  subject: 'Pickup was missed',
  status: 'open',
  statusLabel: 'Ouvert',
  priority: 'high',
  priorityLabel: 'Haute',
  requester: const TicketRequester(name: 'Ada', email: 'ada@example.com'),
  slaBreached: true,
  createdAt: DateTime.utc(2026, 9, 27, 14, 30),
  updatedAt: DateTime.utc(2026, 9, 27, 14, 30),
);

Future<void> _settle(WidgetTester tester) async {
  // The loading shimmer animates forever, so pumpAndSettle would never
  // return; a few frames let the fake request finish.
  for (var i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

void main() {
  testWidgets('a load failure reads in the app language', (tester) async {
    final api = _FakeApi(
      error: DioException(requestOptions: RequestOptions(path: '/tickets')),
    );
    await tester.pumpWidget(_app(api, locale: const Locale('fr', 'CA')));
    await _settle(tester);

    expect(find.text('Impossible de charger les tickets.'), findsOneWidget);
    expect(find.text('Failed to load tickets.'), findsNothing);
    expect(find.text('Réessayer'), findsOneWidget);
  });

  testWidgets('the create button takes the host primary colour', (
    tester,
  ) async {
    await tester.pumpWidget(_app(_FakeApi(result: _page([]))));
    await _settle(tester);

    final fab = tester.widget<FloatingActionButton>(
      find.byType(FloatingActionButton),
    );
    expect(fab.backgroundColor, _hostTheme.colorScheme.primary);
    expect(fab.foregroundColor, _hostTheme.colorScheme.onPrimary);
  });

  testWidgets('a host FAB theme wins over the primary colour', (tester) async {
    const fabColour = Color(0xFFFF6B00);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          apiServiceProvider.overrideWithValue(_FakeApi(result: _page([]))),
        ],
        child: MaterialApp(
          theme: _hostTheme.copyWith(
            floatingActionButtonTheme: const FloatingActionButtonThemeData(
              backgroundColor: fabColour,
            ),
          ),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
          ],
          home: const TicketListScreen(),
        ),
      ),
    );
    await _settle(tester);

    final fab = tester.widget<FloatingActionButton>(
      find.byType(FloatingActionButton),
    );
    expect(fab.backgroundColor, fabColour);
  });

  testWidgets('ticket references use the host primary, not a fixed indigo', (
    tester,
  ) async {
    await tester.pumpWidget(_app(_FakeApi(result: _page([_ticket]))));
    await _settle(tester);

    final reference = tester.widget<Text>(find.text('ESC-00042'));
    expect(reference.style?.color, _hostTheme.colorScheme.primary);
  });

  testWidgets('dates follow the app locale', (tester) async {
    await tester.pumpWidget(
      _app(_FakeApi(result: _page([_ticket])), locale: const Locale('fr')),
    );
    await _settle(tester);

    // French medium date: "27 sept. 2026", not "Sep 27, 2026".
    expect(find.textContaining('sept. 2026'), findsOneWidget);
    expect(find.textContaining('Sep 27'), findsNothing);
  });
}
