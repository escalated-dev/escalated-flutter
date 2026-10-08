import 'json_read.dart';

class Attachment {
  final int id;
  final String filename;
  final String mimeType;
  final int size;
  final String url;

  const Attachment({
    required this.id,
    required this.filename,
    required this.mimeType,
    required this.size,
    required this.url,
  });

  factory Attachment.fromJson(Map<String, dynamic> json) {
    return Attachment(
      id: readInt(json['id']),
      // The browser payload names it `original_filename`.
      filename: readString(json['filename'] ?? json['original_filename']),
      mimeType: readString(json['mime_type'], 'application/octet-stream'),
      size: readInt(json['size']),
      // Guest download links are signed and expire with the access grant;
      // open them as given, without adding credentials.
      url: readString(json['url']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'filename': filename,
      'mime_type': mimeType,
      'size': size,
      'url': url,
    };
  }

  String get formattedSize {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  bool get isImage => mimeType.startsWith('image/');
  bool get isPdf => mimeType == 'application/pdf';
  bool get isDocument =>
      mimeType.contains('word') ||
      mimeType.contains('document') ||
      mimeType.contains('text/');
  bool get isSpreadsheet =>
      mimeType.contains('excel') ||
      mimeType.contains('spreadsheet') ||
      mimeType.contains('csv');
  bool get isArchive =>
      mimeType.contains('zip') ||
      mimeType.contains('rar') ||
      mimeType.contains('tar') ||
      mimeType.contains('gz');
}
