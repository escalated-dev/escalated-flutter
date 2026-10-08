import 'json_read.dart';

class Tag {
  final int id;
  final String name;
  final String? color;

  const Tag({required this.id, required this.name, this.color});

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      id: readInt(json['id']),
      name: readString(json['name']),
      color: readOptionalString(json['color']),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, if (color != null) 'color': color};
  }
}
