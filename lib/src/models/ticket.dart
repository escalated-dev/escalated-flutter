import 'json_read.dart';
import 'reply.dart';
import 'tag.dart';
import 'ticket_summary.dart';

class TicketStatusField {
  final String value;
  final String label;

  const TicketStatusField({required this.value, required this.label});

  factory TicketStatusField.fromJson(Map<String, dynamic> json) {
    final value = readString(json['value']);
    return TicketStatusField(
      value: value,
      label: readString(json['label'], value),
    );
  }

  /// Reads `{value, label}`, or a bare status string as both.
  factory TicketStatusField.read(Object? json) {
    if (json is Map) {
      return TicketStatusField.fromJson(Map<String, dynamic>.from(json));
    }
    final value = readString(json);
    return TicketStatusField(value: value, label: value);
  }

  Map<String, dynamic> toJson() {
    return {'value': value, 'label': label};
  }
}

class TicketSla {
  final String? firstResponseDueAt;
  final String? firstResponseAt;
  final bool firstResponseBreached;
  final String? resolutionDueAt;
  final bool resolutionBreached;

  const TicketSla({
    this.firstResponseDueAt,
    this.firstResponseAt,
    required this.firstResponseBreached,
    this.resolutionDueAt,
    required this.resolutionBreached,
  });

  factory TicketSla.fromJson(Map<String, dynamic> json) {
    return TicketSla(
      firstResponseDueAt: readOptionalString(json['first_response_due_at']),
      firstResponseAt: readOptionalString(json['first_response_at']),
      firstResponseBreached: json['first_response_breached'] == true,
      resolutionDueAt: readOptionalString(json['resolution_due_at']),
      resolutionBreached: json['resolution_breached'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'first_response_due_at': firstResponseDueAt,
      'first_response_at': firstResponseAt,
      'first_response_breached': firstResponseBreached,
      'resolution_due_at': resolutionDueAt,
      'resolution_breached': resolutionBreached,
    };
  }
}

class TicketAssigneeDetail {
  final int id;
  final String name;
  final String email;

  const TicketAssigneeDetail({
    required this.id,
    required this.name,
    required this.email,
  });

  factory TicketAssigneeDetail.fromJson(Map<String, dynamic> json) {
    // A requester sees the assigned agent by display name only: `id` 0 and
    // an empty `email`.
    return TicketAssigneeDetail(
      id: readInt(json['id']),
      name: readString(json['name']),
      email: readString(json['email']),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'email': email};
  }
}

class Ticket {
  final int id;
  final String reference;

  /// The verified guest access grant returned when a guest ticket is created.
  ///
  /// An opaque, expiring credential: do not parse it, put it in a URL the
  /// user can share, or log it. `GuestAccessService` stores it per ticket.
  final String? guestAccessToken;

  /// When [guestAccessToken] stops working.
  final DateTime? guestAccessExpiresAt;
  final String subject;
  final String description;
  final TicketStatusField status;
  final TicketStatusField priority;
  final String channel;
  final Map<String, dynamic> metadata;
  final TicketRequester requester;
  final TicketAssigneeDetail? assignee;
  final TicketDepartment? department;
  final List<Tag> tags;
  final List<Reply> replies;
  final List<dynamic> activities;
  final TicketSla? sla;
  final bool isFollowing;
  final int followersCount;
  final DateTime? resolvedAt;
  final DateTime? closedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Ticket({
    required this.id,
    required this.reference,
    this.guestAccessToken,
    this.guestAccessExpiresAt,
    required this.subject,
    required this.description,
    required this.status,
    required this.priority,
    required this.channel,
    required this.metadata,
    required this.requester,
    this.assignee,
    this.department,
    required this.tags,
    required this.replies,
    required this.activities,
    this.sla,
    required this.isFollowing,
    required this.followersCount,
    this.resolvedAt,
    this.closedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Reads a ticket payload.
  ///
  /// Tolerant of the allow-listed payload a verified guest receives: staff
  /// by display name only, `metadata` as `{}` or `[]`, and backends that
  /// omit the id or send statuses as plain strings.
  factory Ticket.fromJson(Map<String, dynamic> json) {
    final createdAt = readDate(json['created_at']);
    final updatedAt = readDate(json['updated_at']);
    final assignee = readMap(json['assignee']);
    final department = readMap(json['department']);
    final sla = readMap(json['sla']);

    return Ticket(
      id: readInt(json['id']),
      reference: readString(json['reference']),
      guestAccessToken: readOptionalString(json['guest_access_token']),
      // Mobile creation names it `guest_access_expires_at`; lookup results
      // and some backends use `expires_at`.
      guestAccessExpiresAt: readDate(
        json['guest_access_expires_at'] ?? json['expires_at'],
      ),
      subject: readString(json['subject']),
      description: readString(json['description']),
      status: TicketStatusField.read(json['status']),
      priority: TicketStatusField.read(json['priority']),
      channel: readString(json['channel'], 'web'),
      metadata: readMap(json['metadata']) ?? <String, dynamic>{},
      requester: TicketRequester.fromJson(
        readMap(json['requester']) ?? const <String, dynamic>{},
      ),
      assignee: assignee != null
          ? TicketAssigneeDetail.fromJson(assignee)
          : null,
      department: department != null
          ? TicketDepartment.fromJson(department)
          : null,
      tags: readMapList(json['tags']).map(Tag.fromJson).toList(),
      replies: readMapList(json['replies']).map(Reply.fromJson).toList(),
      activities: json['activities'] is List
          ? json['activities'] as List<dynamic>
          : const [],
      sla: sla != null ? TicketSla.fromJson(sla) : null,
      isFollowing: json['is_following'] == true,
      followersCount: readInt(json['followers_count']),
      resolvedAt: readDate(json['resolved_at']),
      closedAt: readDate(json['closed_at']),
      createdAt:
          createdAt ??
          updatedAt ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      updatedAt:
          updatedAt ??
          createdAt ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reference': reference,
      if (guestAccessToken != null) 'guest_access_token': guestAccessToken,
      if (guestAccessExpiresAt != null)
        'guest_access_expires_at': guestAccessExpiresAt!.toIso8601String(),
      'subject': subject,
      'description': description,
      'status': status.toJson(),
      'priority': priority.toJson(),
      'channel': channel,
      'metadata': metadata,
      'requester': requester.toJson(),
      if (assignee != null) 'assignee': assignee!.toJson(),
      if (department != null) 'department': department!.toJson(),
      'tags': tags.map((t) => t.toJson()).toList(),
      'replies': replies.map((r) => r.toJson()).toList(),
      'activities': activities,
      if (sla != null) 'sla': sla!.toJson(),
      'is_following': isFollowing,
      'followers_count': followersCount,
      if (resolvedAt != null) 'resolved_at': resolvedAt!.toIso8601String(),
      if (closedAt != null) 'closed_at': closedAt!.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  bool get isResolved => status.value == 'resolved';
  bool get isClosed => status.value == 'closed';
  bool get isOpen => status.value == 'open';

  /// What to put in a guest ticket route.
  ///
  /// Guest routes used to carry the permanent guest token. Servers now issue
  /// expiring, verified access grants instead, which must not travel in a
  /// route or a shareable link, so this is the ticket [reference]. Look the
  /// grant up with `GuestAccessService`.
  @Deprecated(
    'Route guest screens by `reference`. The access token now lives in '
    'GuestAccessStore. Will be removed in the next major release.',
  )
  String get guestRouteReference => reference;
}
