import 'attachment.dart';

class ReplyAuthor {
  final int id;
  final String name;
  final String email;

  const ReplyAuthor({
    required this.id,
    required this.name,
    required this.email,
  });

  factory ReplyAuthor.fromJson(Map<String, dynamic> json) {
    return ReplyAuthor(
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

class Reply {
  final int id;
  final String body;
  final bool isInternalNote;
  final bool isPinned;
  final ReplyAuthor author;
  final List<Attachment> attachments;
  final DateTime createdAt;

  const Reply({
    required this.id,
    required this.body,
    required this.isInternalNote,
    required this.isPinned,
    required this.author,
    required this.attachments,
    required this.createdAt,
  });

  factory Reply.fromJson(Map<String, dynamic> json) {
    return Reply(
      id: json['id'] as int,
      body: json['body'] as String,
      isInternalNote: json['is_internal_note'] as bool? ?? false,
      isPinned: json['is_pinned'] as bool? ?? false,
      author: ReplyAuthor.fromJson(json['author'] as Map<String, dynamic>),
      attachments: (json['attachments'] as List<dynamic>?)
              ?.map((a) => Attachment.fromJson(a as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'body': body,
      'is_internal_note': isInternalNote,
      'is_pinned': isPinned,
      'author': author.toJson(),
      'attachments': attachments.map((a) => a.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}
