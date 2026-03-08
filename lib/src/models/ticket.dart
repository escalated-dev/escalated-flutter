import 'reply.dart';
import 'tag.dart';
import 'ticket_summary.dart';

class TicketStatusField {
  final String value;
  final String label;

  const TicketStatusField({
    required this.value,
    required this.label,
  });

  factory TicketStatusField.fromJson(Map<String, dynamic> json) {
    return TicketStatusField(
      value: json['value'] as String,
      label: json['label'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'label': label,
    };
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
      firstResponseDueAt: json['first_response_due_at'] as String?,
      firstResponseAt: json['first_response_at'] as String?,
      firstResponseBreached: json['first_response_breached'] as bool? ?? false,
      resolutionDueAt: json['resolution_due_at'] as String?,
      resolutionBreached: json['resolution_breached'] as bool? ?? false,
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
    return TicketAssigneeDetail(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
    };
  }
}

class Ticket {
  final int id;
  final String reference;
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

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['id'] as int,
      reference: json['reference'] as String,
      subject: json['subject'] as String,
      description: json['description'] as String? ?? '',
      status:
          TicketStatusField.fromJson(json['status'] as Map<String, dynamic>),
      priority:
          TicketStatusField.fromJson(json['priority'] as Map<String, dynamic>),
      channel: json['channel'] as String? ?? 'web',
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
      requester:
          TicketRequester.fromJson(json['requester'] as Map<String, dynamic>),
      assignee: json['assignee'] != null
          ? TicketAssigneeDetail.fromJson(
              json['assignee'] as Map<String, dynamic>)
          : null,
      department: json['department'] != null
          ? TicketDepartment.fromJson(
              json['department'] as Map<String, dynamic>)
          : null,
      tags: (json['tags'] as List<dynamic>?)
              ?.map((t) => Tag.fromJson(t as Map<String, dynamic>))
              .toList() ??
          [],
      replies: (json['replies'] as List<dynamic>?)
              ?.map((r) => Reply.fromJson(r as Map<String, dynamic>))
              .toList() ??
          [],
      activities: json['activities'] as List<dynamic>? ?? [],
      sla: json['sla'] != null
          ? TicketSla.fromJson(json['sla'] as Map<String, dynamic>)
          : null,
      isFollowing: json['is_following'] as bool? ?? false,
      followersCount: json['followers_count'] as int? ?? 0,
      resolvedAt: json['resolved_at'] != null
          ? DateTime.parse(json['resolved_at'] as String)
          : null,
      closedAt: json['closed_at'] != null
          ? DateTime.parse(json['closed_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reference': reference,
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
}
