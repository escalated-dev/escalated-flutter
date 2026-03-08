import 'package:dio/dio.dart';
import 'auth_hooks.dart';

class ApiClient {
  late final Dio dio;
  final AuthHooks authHooks;
  final String baseUrl;

  ApiClient({
    required this.authHooks,
    required this.baseUrl,
    Dio? dioInstance,
  }) {
    dio = dioInstance ?? Dio();
    dio.options.baseUrl = baseUrl;
    dio.options.connectTimeout = const Duration(seconds: 30);
    dio.options.receiveTimeout = const Duration(seconds: 30);
    dio.options.headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    dio.interceptors.add(_AuthInterceptor(authHooks));
    dio.interceptors.add(LogInterceptor(
      requestBody: false,
      responseBody: false,
    ));
  }
}

class _AuthInterceptor extends Interceptor {
  final AuthHooks _authHooks;

  _AuthInterceptor(this._authHooks);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final headers = await _authHooks.getAuthHeaders();
    options.headers.addAll(headers);
    handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final statusCode = err.response?.statusCode;
    if (statusCode != null) {
      final body = err.response?.data is Map<String, dynamic>
          ? err.response!.data as Map<String, dynamic>
          : <String, dynamic>{};
      final recovered = await _authHooks.onAuthError(statusCode, body);
      if (recovered) {
        // Retry the original request with refreshed headers
        try {
          final headers = await _authHooks.getAuthHeaders();
          final opts = err.requestOptions;
          opts.headers.addAll(headers);
          final response = await Dio().fetch(opts);
          return handler.resolve(response);
        } catch (_) {
          // Fall through to error
        }
      }
    }
    handler.next(err);
  }
}
