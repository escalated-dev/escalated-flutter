import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:escalated/escalated.dart';

/// A request the fake server received.
class RecordedRequest {
  RecordedRequest(this.method, this.path, this.headers, this.body);

  final String method;
  final String path;
  final Map<String, dynamic> headers;

  /// JSON bodies decoded to a map; form bodies as their text fields.
  final Map<String, dynamic> body;
}

class FakeResponse {
  const FakeResponse(this.status, [this.body, this.headers = const {}]);

  final int status;
  final Object? body;
  final Map<String, List<String>> headers;
}

typedef FakeHandler = FakeResponse Function(RecordedRequest request);

/// Answers Dio requests from a table of `METHOD /path` handlers and records
/// every request. Unmatched requests get a 500 so a test fails loudly.
class FakeServer implements HttpClientAdapter {
  final Map<String, FakeHandler> _routes = {};
  final List<RecordedRequest> requests = [];

  void on(String method, String path, FakeHandler handler) {
    _routes['$method $path'] = handler;
  }

  void reply(String method, String path, FakeResponse response) {
    on(method, path, (_) => response);
  }

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final body = <String, dynamic>{};
    final data = options.data;
    if (data is FormData) {
      for (final field in data.fields) {
        body[field.key] = field.value;
      }
    } else if (data is Map) {
      body.addAll(Map<String, dynamic>.from(data));
    }
    // Drain the stream Dio hands us so it does not complain.
    if (requestStream != null) await requestStream.drain<void>();

    final request = RecordedRequest(
      options.method,
      options.uri.path,
      Map<String, dynamic>.from(options.headers),
      body,
    );
    requests.add(request);

    final handler = _routes['${options.method} ${options.uri.path}'];
    final response = handler != null
        ? handler(request)
        : const FakeResponse(500, {'message': 'No fake route'});

    return ResponseBody.fromString(
      jsonEncode(response.body ?? {}),
      response.status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
        ...response.headers,
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

class NoAuthHooks extends AuthHooks {
  @override
  Future<Map<String, String>> getAuthHeaders() async => {};

  @override
  Future<bool> onAuthError(int statusCode, Map<String, dynamic> body) async =>
      false;

  @override
  Future<AuthResult> onLogin(String email, String password) =>
      throw UnimplementedError();

  @override
  Future<void> onLogout() async {}

  @override
  Future<AuthResult> onRegister(Map<String, dynamic> data) =>
      throw UnimplementedError();

  @override
  Future<String?> onTokenRefresh() async => null;
}

const String apiPrefix = '/support/api/v1/mobile';

ApiService fakeApi(FakeServer server) {
  final dio = Dio()..httpClientAdapter = server;
  return ApiService(
    ApiClient(
      authHooks: NoAuthHooks(),
      baseUrl: 'https://help.example.test$apiPrefix',
      dioInstance: dio,
    ),
  );
}

/// A ticket as Laravel's MobileTicketResource sends it to a verified guest.
Map<String, dynamic> guestTicketJson({
  String reference = 'ESC-00042',
  String? token,
  String? expiresAt,
  List<Map<String, dynamic>> replies = const [],
}) {
  return {
    'id': 42,
    'reference': reference,
    'guest_access_token': token,
    'guest_access_expires_at': token == null ? null : expiresAt,
    'subject': 'Parcel never arrived',
    'description': 'Tracking stopped on Monday.',
    'status': {'value': 'open', 'label': 'Open'},
    'priority': {'value': 'medium', 'label': 'Medium'},
    'channel': 'web',
    'metadata': <String, dynamic>{},
    'requester': {'name': 'Ada Guest', 'email': 'ada@example.com'},
    'assignee': {'id': 0, 'name': 'Sam Agent', 'email': ''},
    'department': {'id': 3, 'name': 'Shipping'},
    'tags': [],
    'replies': replies,
    'activities': [],
    'sla': {
      'first_response_due_at': null,
      'first_response_at': null,
      'first_response_breached': false,
      'resolution_due_at': null,
      'resolution_breached': false,
    },
    'is_following': false,
    'followers_count': 0,
    'resolved_at': null,
    'closed_at': null,
    'created_at': '2026-10-01T09:00:00+00:00',
    'updated_at': '2026-10-01T09:00:00+00:00',
  };
}
