import 'attachment.dart';
import 'json_read.dart';

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
    // Staff appear to a requester by display name only: `id` 0 and an
    // empty `email`.
    return ReplyAuthor(
      id: readInt(json['id']),
      name: readString(json['name']),
      email: readString(json['email']),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'email': email};
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
      id: readInt(json['id']),
      body: readString(json['body']),
      isInternalNote: json['is_internal_note'] == true,
      isPinned: json['is_pinned'] == true,
      author: ReplyAuthor.fromJson(
        readMap(json['author']) ?? const <String, dynamic>{},
      ),
      attachments: readMapList(
        json['attachments'],
      ).map(Attachment.fromJson).toList(),
      createdAt:
          readDate(json['created_at']) ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
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
