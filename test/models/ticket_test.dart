import 'package:escalated/src/models/ticket.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'ticket parses guest access token and exposes guest route reference',
    () {
      final ticket = Ticket.fromJson({
        'id': 1,
        'reference': 'ESC-12345',
        'guest_access_token': 'guest-token-abc',
        'subject': 'Need help',
        'description': 'Description',
        'status': {'value': 'open', 'label': 'Open'},
        'priority': {'value': 'medium', 'label': 'Medium'},
        'channel': 'web',
        'metadata': {},
        'requester': {'name': 'Guest User', 'email': 'guest@example.com'},
        'tags': [],
        'replies': [],
        'activities': [],
        'sla': {
          'first_response_due_at': null,
          'first_response_at': null,
          'first_response_breached': false,
          'resolution_due_at': null,
          'resolution_breached': false,
        },
        'is_following': false,
        'followers_count': 0,
        'created_at': '2026-05-26T00:00:00Z',
        'updated_at': '2026-05-26T00:00:00Z',
      });

      expect(ticket.reference, 'ESC-12345');
      expect(ticket.guestAccessToken, 'guest-token-abc');
      expect(ticket.guestRouteReference, 'guest-token-abc');
    },
  );

  test('ticket guest route reference falls back to reference', () {
    final ticket = Ticket.fromJson({
      'id': 2,
      'reference': 'ESC-12346',
      'subject': 'Need help',
      'description': 'Description',
      'status': {'value': 'open', 'label': 'Open'},
      'priority': {'value': 'medium', 'label': 'Medium'},
      'channel': 'web',
      'metadata': {},
      'requester': {'name': 'Guest User', 'email': 'guest@example.com'},
      'tags': [],
      'replies': [],
      'activities': [],
      'sla': {
        'first_response_due_at': null,
        'first_response_at': null,
        'first_response_breached': false,
        'resolution_due_at': null,
        'resolution_breached': false,
      },
      'is_following': false,
      'followers_count': 0,
      'created_at': '2026-05-26T00:00:00Z',
      'updated_at': '2026-05-26T00:00:00Z',
    });

    expect(ticket.guestAccessToken, isNull);
    expect(ticket.guestRouteReference, 'ESC-12346');
  });
}
