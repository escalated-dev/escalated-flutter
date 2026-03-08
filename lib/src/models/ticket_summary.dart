class TicketRequester {
  final String name;
  final String email;

  const TicketRequester({
    required this.name,
    required this.email,
  });

  factory TicketRequester.fromJson(Map<String, dynamic> json) {
    return TicketRequester(
      name: json['name'] as String,
      email: json['email'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
    };
  }
}

class TicketAssignee {
  final int id;
  final String name;

  const TicketAssignee({
    required this.id,
    required this.name,
  });

  factory TicketAssignee.fromJson(Map<String, dynamic> json) {
    return TicketAssignee(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class TicketDepartment {
  final int id;
  final String name;

  const TicketDepartment({
    required this.id,
    required this.name,
  });

  factory TicketDepartment.fromJson(Map<String, dynamic> json) {
    return TicketDepartment(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class TicketSummary {
  final int id;
  final String reference;
  final String subject;
  final String status;
  final String statusLabel;
  final String priority;
  final String priorityLabel;
  final TicketRequester requester;
  final TicketAssignee? assignee;
  final TicketDepartment? department;
  final bool slaBreached;
  final DateTime? lastReplyAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TicketSummary({
    required this.id,
    required this.reference,
    required this.subject,
    required this.status,
    required this.statusLabel,
    required this.priority,
    required this.priorityLabel,
    required this.requester,
    this.assignee,
    this.department,
    required this.slaBreached,
    this.lastReplyAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TicketSummary.fromJson(Map<String, dynamic> json) {
    return TicketSummary(
      id: json['id'] as int,
      reference: json['reference'] as String,
      subject: json['subject'] as String,
      status: json['status'] as String,
      statusLabel: json['status_label'] as String,
      priority: json['priority'] as String,
      priorityLabel: json['priority_label'] as String,
      requester:
          TicketRequester.fromJson(json['requester'] as Map<String, dynamic>),
      assignee: json['assignee'] != null
          ? TicketAssignee.fromJson(json['assignee'] as Map<String, dynamic>)
          : null,
      department: json['department'] != null
          ? TicketDepartment.fromJson(
              json['department'] as Map<String, dynamic>)
          : null,
      slaBreached: json['sla_breached'] as bool? ?? false,
      lastReplyAt: json['last_reply_at'] != null
          ? DateTime.parse(json['last_reply_at'] as String)
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
      'status': status,
      'status_label': statusLabel,
      'priority': priority,
      'priority_label': priorityLabel,
      'requester': requester.toJson(),
      if (assignee != null) 'assignee': assignee!.toJson(),
      if (department != null) 'department': department!.toJson(),
      'sla_breached': slaBreached,
      if (lastReplyAt != null) 'last_reply_at': lastReplyAt!.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
