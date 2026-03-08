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
      id: json['id'] as int,
      filename: json['filename'] as String,
      mimeType: json['mime_type'] as String,
      size: json['size'] as int,
      url: json['url'] as String,
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
