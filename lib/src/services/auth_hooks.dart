import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Result of an authentication operation (login/register).
class AuthResult {
  final String token;
  final Map<String, dynamic> user;
  const AuthResult({required this.token, required this.user});
}

/// Abstract auth hooks class that consumers can override
/// to provide their own authentication mechanism.
abstract class AuthHooks {
  /// Perform login with email and password, returning an [AuthResult].
  Future<AuthResult> onLogin(String email, String password);

  /// Perform logout (clear session).
  Future<void> onLogout();

  /// Attempt to refresh the auth token. Returns the new token or null.
  Future<String?> onTokenRefresh();

  /// Handle an auth error. If 401, attempt token refresh.
  /// Returns true if the error was recovered from.
  Future<bool> onAuthError(int statusCode, Map<String, dynamic> body);

  /// Register a new user, returning an [AuthResult].
  Future<AuthResult> onRegister(Map<String, dynamic> data);

  /// Get authorization headers for API requests.
  Future<Map<String, String>> getAuthHeaders();
}

/// Default implementation using Bearer token, Dio for HTTP, and FlutterSecureStorage.
class DefaultAuthHooks extends AuthHooks {
  final FlutterSecureStorage _storage;
  final String apiBaseUrl;
  late final Dio _dio;

  static const String _tokenKey = 'escalated_auth_token';

  DefaultAuthHooks({
    required this.apiBaseUrl,
    FlutterSecureStorage? storage,
    Dio? dio,
  }) : _storage = storage ?? const FlutterSecureStorage() {
    _dio = dio ?? Dio(BaseOptions(
      baseUrl: apiBaseUrl,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ));
  }

  @override
  Future<AuthResult> onLogin(String email, String password) async {
    final response = await _dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    final data = response.data as Map<String, dynamic>;
    final token = data['token'] as String? ??
        (data['data'] as Map<String, dynamic>?)?['token'] as String? ??
        '';
    await _storage.write(key: _tokenKey, value: token);
    final user = data['user'] as Map<String, dynamic>? ??
        (data['data'] as Map<String, dynamic>?)?['user'] as Map<String, dynamic>? ??
        data;
    return AuthResult(token: token, user: user);
  }

  @override
  Future<void> onLogout() async {
    await _storage.delete(key: _tokenKey);
  }

  @override
  Future<String?> onTokenRefresh() async {
    try {
      final currentToken = await _storage.read(key: _tokenKey);
      if (currentToken == null) return null;

      final response = await _dio.post(
        '/auth/refresh',
        options: Options(headers: {'Authorization': 'Bearer $currentToken'}),
      );
      final data = response.data as Map<String, dynamic>;
      final newToken = data['token'] as String? ??
          (data['data'] as Map<String, dynamic>?)?['token'] as String?;
      if (newToken != null) {
        await _storage.write(key: _tokenKey, value: newToken);
      }
      return newToken;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<bool> onAuthError(int statusCode, Map<String, dynamic> body) async {
    if (statusCode == 401) {
      final newToken = await onTokenRefresh();
      return newToken != null;
    }
    return false;
  }

  @override
  Future<AuthResult> onRegister(Map<String, dynamic> data) async {
    final response = await _dio.post('/auth/register', data: data);
    final responseData = response.data as Map<String, dynamic>;
    final token = responseData['token'] as String? ??
        (responseData['data'] as Map<String, dynamic>?)?['token'] as String? ??
        '';
    await _storage.write(key: _tokenKey, value: token);
    final user = responseData['user'] as Map<String, dynamic>? ??
        (responseData['data'] as Map<String, dynamic>?)?['user'] as Map<String, dynamic>? ??
        responseData;
    return AuthResult(token: token, user: user);
  }

  @override
  Future<Map<String, String>> getAuthHeaders() async {
    final token = await _storage.read(key: _tokenKey);
    if (token == null || token.isEmpty) {
      return {};
    }
    return {'Authorization': 'Bearer $token'};
  }
}
