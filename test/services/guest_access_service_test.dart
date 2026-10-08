import 'package:escalated/escalated.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fake_server.dart';

void main() {
  late FakeServer server;
  late InMemoryGuestAccessStore store;
  late DateTime now;
  late GuestAccessService guest;

  const verificationId = '0d9b6a1e-5f3c-4b8e-9a1d-2c4e6f8a0b1c';
  const grant = 'eyJpdiI6IkFCQyJ9-sealed_grant';

  setUp(() {
    server = FakeServer();
    store = InMemoryGuestAccessStore();
    now = DateTime.utc(2026, 10, 1, 12);
    guest = GuestAccessService(fakeApi(server), store, clock: () => now);
  });

  GuestVerificationChallenge challenge(GuestVerificationPurpose purpose) =>
      GuestVerificationChallenge(
        verificationId: verificationId,
        expiresIn: const Duration(minutes: 10),
        email: 'ada@example.com',
        purpose: purpose,
      );

  group('requesting a code', () {
    test('posts the email and purpose and reads the challenge', () async {
      server.reply(
        'POST',
        '$apiPrefix/guest/verification',
        const FakeResponse(202, {
          'verification_id': verificationId,
          'expires_in': 600,
          'message': 'Check your email for a verification code.',
        }),
      );

      final result = await guest.requestCode(
        email: ' ada@example.com ',
        purpose: GuestVerificationPurpose.lookup,
      );

      expect(server.requests.single.body, {
        'email': 'ada@example.com',
        'purpose': 'lookup',
      });
      expect(result.verificationId, verificationId);
      expect(result.expiresIn, const Duration(minutes: 10));
      expect(result.email, 'ada@example.com');
      expect(result.purpose, GuestVerificationPurpose.lookup);
    });

    test('a 429 carries Retry-After', () async {
      server.reply(
        'POST',
        '$apiPrefix/guest/verification',
        const FakeResponse(
          429,
          {'message': 'Please wait before requesting another code.'},
          {
            'retry-after': ['42'],
          },
        ),
      );

      await expectLater(
        guest.requestCode(
          email: 'ada@example.com',
          purpose: GuestVerificationPurpose.ticket,
        ),
        throwsA(
          isA<GuestRateLimitedException>()
              .having(
                (e) => e.retryAfter,
                'retryAfter',
                const Duration(seconds: 42),
              )
              .having((e) => e.messageKey, 'messageKey', 'guest_rate_limited'),
        ),
      );
    });

    test('a 429 without Retry-After asks to try later', () async {
      server.reply(
        'POST',
        '$apiPrefix/guest/verification',
        const FakeResponse(429, {'message': 'Too Many Attempts.'}),
      );

      await expectLater(
        guest.requestCode(
          email: 'ada@example.com',
          purpose: GuestVerificationPurpose.ticket,
        ),
        throwsA(
          isA<GuestRateLimitedException>()
              .having((e) => e.retryAfter, 'retryAfter', isNull)
              .having(
                (e) => e.messageKey,
                'messageKey',
                'guest_rate_limited_later',
              ),
        ),
      );
    });

    test('a 403 means guest tickets are off', () async {
      server.reply(
        'POST',
        '$apiPrefix/guest/verification',
        const FakeResponse(403, {'message': 'Forbidden'}),
      );

      await expectLater(
        guest.requestCode(
          email: 'ada@example.com',
          purpose: GuestVerificationPurpose.ticket,
        ),
        throwsA(isA<GuestTicketsDisabledException>()),
      );
    });
  });

  group('creating a ticket', () {
    test('sends the proof and stores the grant for the ticket', () async {
      server.reply(
        'POST',
        '$apiPrefix/guest/tickets',
        FakeResponse(201, {
          'data': guestTicketJson(
            token: grant,
            expiresAt: '2026-10-02T12:00:00+00:00',
          ),
          'message': 'Ticket created.',
        }),
      );

      final ticket = await guest.createTicket(
        challenge: challenge(GuestVerificationPurpose.ticket),
        code: ' 12345678 ',
        name: 'Ada Guest',
        subject: 'Parcel never arrived',
        description: 'Tracking stopped on Monday.',
        priority: 'medium',
      );

      final sent = server.requests.single.body;
      expect(sent['name'], 'Ada Guest');
      expect(sent['email'], 'ada@example.com');
      expect(sent['verification_id'], verificationId);
      expect(sent['verification_code'], '12345678');
      expect(sent, isNot(contains('guest_token')));

      expect(ticket.reference, 'ESC-00042');
      final stored = await store.read('ESC-00042');
      expect(stored!.token, grant);
      expect(stored.expiresAt, DateTime.utc(2026, 10, 2, 12));
      expect(stored.email, 'ada@example.com');
    });

    test('a wrong code is a verification failure', () async {
      server.reply(
        'POST',
        '$apiPrefix/guest/tickets',
        const FakeResponse(422, {
          'message': 'The given data was invalid.',
          'errors': {
            'verification_code': [
              'This code is invalid, expired or already used. '
                  'Request a new code.',
            ],
          },
        }),
      );

      await expectLater(
        guest.createTicket(
          challenge: challenge(GuestVerificationPurpose.ticket),
          code: '00000000',
          name: 'Ada',
          subject: 's',
          description: 'd',
        ),
        throwsA(
          isA<GuestVerificationFailedException>().having(
            (e) => e.messageKey,
            'messageKey',
            startsWith('This code is invalid'),
          ),
        ),
      );
      expect(await store.read('ESC-00042'), isNull);
    });

    test('refuses a lookup code', () async {
      expect(
        () => guest.createTicket(
          challenge: challenge(GuestVerificationPurpose.lookup),
          code: '1',
          name: 'Ada',
          subject: 's',
          description: 'd',
        ),
        throwsArgumentError,
      );
      expect(server.requests, isEmpty);
    });
  });

  group('opening a ticket', () {
    setUp(() async {
      await store.write(
        GuestAccessGrant(
          reference: 'ESC-00042',
          token: grant,
          expiresAt: DateTime.utc(2026, 10, 2, 12),
          email: 'ada@example.com',
        ),
      );
    });

    test('sends the grant in the ticket route', () async {
      server.reply(
        'GET',
        '$apiPrefix/guest/tickets/$grant',
        FakeResponse(200, {'data': guestTicketJson()}),
      );

      final ticket = await guest.show('ESC-00042');

      expect(ticket.subject, 'Parcel never arrived');
      expect(server.requests.single.path, '$apiPrefix/guest/tickets/$grant');
    });

    test('replies from the verified email', () async {
      server.reply(
        'POST',
        '$apiPrefix/guest/tickets/$grant/replies',
        const FakeResponse(201, {'message': 'Reply sent.'}),
      );

      await guest.reply(reference: 'ESC-00042', body: 'Any news?');

      expect(server.requests.single.body, {
        'body': 'Any news?',
        'email': 'ada@example.com',
      });
    });

    test('an expired grant needs verification and makes no request', () async {
      now = DateTime.utc(2026, 10, 2, 12);

      await expectLater(
        guest.show('ESC-00042'),
        throwsA(
          isA<GuestAccessRequiredException>().having(
            (e) => e.reason,
            'reason',
            GuestAccessRequiredReason.expired,
          ),
        ),
      );
      expect(server.requests, isEmpty);
      expect(await store.read('ESC-00042'), isNull);
    });

    test('a refused grant (404) is forgotten', () async {
      server.reply(
        'GET',
        '$apiPrefix/guest/tickets/$grant',
        const FakeResponse(404, {'message': 'Not Found'}),
      );

      await expectLater(
        guest.show('ESC-00042'),
        throwsA(
          isA<GuestAccessRequiredException>().having(
            (e) => e.reason,
            'reason',
            GuestAccessRequiredReason.rejected,
          ),
        ),
      );
      expect(await store.read('ESC-00042'), isNull);
    });

    test('a refused reply (404) is forgotten too', () async {
      server.reply(
        'POST',
        '$apiPrefix/guest/tickets/$grant/replies',
        const FakeResponse(404, {'message': 'Not Found'}),
      );

      await expectLater(
        guest.reply(reference: 'ESC-00042', body: 'Hello?'),
        throwsA(isA<GuestAccessRequiredException>()),
      );
      expect(await store.read('ESC-00042'), isNull);
    });

    test('a link from before verified access has no grant', () async {
      // Old links carried a 64-character permanent token as the route
      // parameter. The app now routes by reference, so there is nothing
      // stored for it and the guest is asked to verify.
      await expectLater(
        guest.show('a' * 64),
        throwsA(
          isA<GuestAccessRequiredException>().having(
            (e) => e.reason,
            'reason',
            GuestAccessRequiredReason.missing,
          ),
        ),
      );
      expect(server.requests, isEmpty);
    });

    test('the server refusing an old permanent token is a 404', () async {
      server.reply(
        'GET',
        '$apiPrefix/guest/tickets/${'a' * 64}',
        const FakeResponse(404, {'message': 'Not Found'}),
      );

      await expectLater(
        fakeApi(server).getGuestTicket('a' * 64),
        throwsA(isA<GuestAccessRequiredException>()),
      );
    });
  });

  group('lookup', () {
    test('posts the proof and stores a fresh grant per ticket', () async {
      await store.write(
        const GuestAccessGrant(reference: 'ESC-00042', token: 'old-grant'),
      );
      server.reply(
        'POST',
        '$apiPrefix/guest/lookup',
        const FakeResponse(200, {
          'data': [
            {
              'reference': 'ESC-00042',
              'subject': 'Parcel never arrived',
              'guest_access_token': 'new-grant',
              'expires_at': '2026-10-02T12:00:00+00:00',
            },
            {
              'reference': 'ESC-00051',
              'subject': 'Second parcel',
              'guest_access_token': 'other-grant',
              'expires_at': '2026-10-02T12:00:00+00:00',
            },
          ],
        }),
      );

      final grants = await guest.lookup(
        challenge: challenge(GuestVerificationPurpose.lookup),
        code: '87654321',
        reference: ' TRACK-123 ',
      );

      expect(server.requests.single.body, {
        'email': 'ada@example.com',
        'reference': 'TRACK-123',
        'verification_id': verificationId,
        'verification_code': '87654321',
      });
      expect(grants.map((g) => g.reference), ['ESC-00042', 'ESC-00051']);
      final renewed = await store.read('ESC-00042');
      expect(renewed!.token, 'new-grant');
      expect(renewed.email, 'ada@example.com');
      expect(renewed.subject, 'Parcel never arrived');
      expect((await store.read('ESC-00051'))!.token, 'other-grant');
    });

    test('no matches is an empty list', () async {
      server.reply(
        'POST',
        '$apiPrefix/guest/lookup',
        const FakeResponse(200, {'data': []}),
      );

      final grants = await guest.lookup(
        challenge: challenge(GuestVerificationPurpose.lookup),
        code: '87654321',
        reference: 'ESC-404',
      );
      expect(grants, isEmpty);
    });
  });

  test('log lines never carry a grant or bearer token', () {
    expect(
      redactCredentials(
        'uri: https://x.test/support/api/v1/mobile/guest/tickets/$grant/replies',
      ),
      'uri: https://x.test/support/api/v1/mobile/guest/tickets/[redacted]/replies',
    );
    expect(
      redactCredentials('Authorization: Bearer abc.def'),
      'Authorization: Bearer [redacted]',
    );
  });

  test('Retry-After is read in seconds', () {
    expect(parseRetryAfter('3600'), const Duration(hours: 1));
    expect(parseRetryAfter(' 5 '), const Duration(seconds: 5));
    expect(parseRetryAfter('Wed, 21 Oct 2026 07:28:00 GMT'), isNull);
    expect(parseRetryAfter(null), isNull);
  });
}
