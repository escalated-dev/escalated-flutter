import 'package:dio/dio.dart';

/// What a provider records as its `error` when a request fails.
///
/// A request the server refused (a 4xx) usually carries a `message` the
/// server wrote for a person, in the language the app asked for; that is kept.
/// Anything else -- no response, a server fault, a body with no message -- is
/// recorded as [fallbackKey], an [AppLocalizations] key. Screens show the
/// error through `AppLocalizations.t`, which translates a key and passes any
/// other text through unchanged, so either kind reads correctly.
String serverMessageOr(DioException e, String fallbackKey) {
  final status = e.response?.statusCode ?? 0;
  final data = e.response?.data;
  final message = data is Map ? data['message'] : null;
  if (status >= 400 &&
      status < 500 &&
      message is String &&
      message.trim().isNotEmpty) {
    return message;
  }
  return fallbackKey;
}
