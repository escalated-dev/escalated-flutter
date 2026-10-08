// Tolerant readers for API payloads.
//
// Requester-facing payloads are allow-listed by the server: a verified guest
// sees staff by display name only (`id: 0`, `email: ''`), `metadata` may be
// an empty object or an empty list, and some backends omit ids or send
// statuses as plain strings. These helpers read what is there and fall back
// instead of throwing on a missing or differently typed field.

/// An int from an int, a num, or a numeric string; [fallback] otherwise.
int readInt(Object? value, [int fallback = 0]) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? fallback;
  return fallback;
}

/// A string from a string or a scalar; [fallback] for null or a structure.
String readString(Object? value, [String fallback = '']) {
  if (value is String) return value;
  if (value is num || value is bool) return '$value';
  return fallback;
}

/// A nullable string: null stays null, a scalar becomes its text.
String? readOptionalString(Object? value) {
  if (value == null) return null;
  if (value is String) return value;
  if (value is num || value is bool) return '$value';
  return null;
}

/// A date from an ISO-8601 string, or null when absent or unparseable.
DateTime? readDate(Object? value) {
  if (value is String && value.isNotEmpty) return DateTime.tryParse(value);
  return null;
}

/// A JSON object as `Map<String, dynamic>`; null for anything else
/// (including the `[]` PHP sends for an empty associative array).
Map<String, dynamic>? readMap(Object? value) {
  if (value is Map) return Map<String, dynamic>.from(value);
  return null;
}

/// The JSON objects in a list, skipping anything that is not one.
List<Map<String, dynamic>> readMapList(Object? value) {
  if (value is! List) return const [];
  return value.whereType<Map>().map(Map<String, dynamic>.from).toList();
}
