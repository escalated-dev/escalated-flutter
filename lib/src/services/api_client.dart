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
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      _authHooks.clearToken();
    }
    handler.next(err);
  }
}
