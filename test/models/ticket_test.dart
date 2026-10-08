import 'package:escalated/escalated.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fake_server.dart';

void main() {
  test('reads the guest access grant and its expiry', () {
    final ticket = Ticket.fromJson(
      guestTicketJson(
        token: 'sealed-grant',
        expiresAt: '2026-10-02T09:00:00+00:00',
      ),
    );

    expect(ticket.reference, 'ESC-00042');
    expect(ticket.guestAccessToken, 'sealed-grant');
    expect(ticket.guestAccessExpiresAt, DateTime.parse('2026-10-02T09:00:00Z'));
  });

  test('guest route reference is the ticket reference, never the grant', () {
    final ticket = Ticket.fromJson(guestTicketJson(token: 'sealed-grant'));

    // ignore: deprecated_member_use_from_same_package
    expect(ticket.guestRouteReference, 'ESC-00042');
  });

  test('reads the allow-listed guest payload', () {
    final json = guestTicketJson(
      replies: [
        {
          'id': 7,
          'body': 'We are checking with the carrier.',
          'is_internal_note': false,
          'is_pinned': false,
          'author': {'id': 0, 'name': 'Sam Agent', 'email': ''},
          'attachments': [
            {
              'id': 5,
              'filename': 'label.pdf',
              'mime_type': 'application/pdf',
              'size': 2048,
              'url': 'https://help.example.test/attachments/5?signature=abc',
            },
          ],
          'created_at': '2026-10-01T10:00:00+00:00',
        },
        {
          'id': 8,
          'body': 'Thanks',
          'author': {'id': 0, 'name': 'Ada Guest', 'email': 'ada@example.com'},
          'attachments': [],
          'created_at': '2026-10-01T11:00:00+00:00',
        },
      ],
    );
    // PHP serializes an empty associative array as a list.
    json['metadata'] = [];

    final ticket = Ticket.fromJson(json);

    expect(ticket.metadata, isEmpty);
    expect(ticket.assignee!.id, 0);
    expect(ticket.assignee!.name, 'Sam Agent');
    expect(ticket.assignee!.email, '');
    expect(ticket.replies.first.author.id, 0);
    expect(ticket.replies.first.author.email, '');
    expect(ticket.replies.first.attachments.single.url, contains('signature'));
    expect(ticket.replies.last.author.name, 'Ada Guest');
  });

  test('reads a sparse guest payload without an id or status labels', () {
    final ticket = Ticket.fromJson({
      'reference': 'ESC-9',
      'subject': 'Hello',
      'status': 'open',
      'priority': 'low',
      'created_at': '2026-10-01T09:00:00Z',
      'guest_access_token': 'grant',
      'expires_at': '2026-10-02T09:00:00Z',
      'description': null,
      'replies': [
        {
          'body': 'Hi',
          'created_at': '2026-10-01T09:30:00',
          'attachments': [
            {
              'filename': 'a.png',
              'mime_type': 'image/png',
              'size': 3,
              'url': 'u',
            },
          ],
        },
      ],
      'attachments': [],
    });

    expect(ticket.id, 0);
    expect(ticket.status.value, 'open');
    expect(ticket.priority.label, 'low');
    expect(ticket.description, '');
    expect(ticket.requester.email, '');
    expect(ticket.updatedAt, ticket.createdAt);
    expect(ticket.guestAccessExpiresAt, DateTime.parse('2026-10-02T09:00:00Z'));
    expect(ticket.replies.single.author.name, '');
    expect(ticket.replies.single.attachments.single.id, 0);
  });

  test('reads attachments named original_filename', () {
    final attachment = Attachment.fromJson({
      'id': '12',
      'original_filename': 'scan.jpg',
      'mime_type': 'image/jpeg',
      'size': 10,
      'url': 'https://x.test/a',
    });
    expect(attachment.id, 12);
    expect(attachment.filename, 'scan.jpg');
  });
}
