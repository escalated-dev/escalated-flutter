import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Abstract auth hooks class that consumers can override
/// to provide their own authentication mechanism.
abstract class AuthHooks {
  /// Get the current auth token, or null if not authenticated.
  Future<String?> getToken();

  /// Store a new auth token after login/register.
  Future<void> setToken(String token);

  /// Remove the stored auth token on logout.
  Future<void> clearToken();

  /// Check if a user is currently authenticated.
  Future<bool> isAuthenticated();

  /// Get authorization headers for API requests.
  Future<Map<String, String>> getAuthHeaders();
}

/// Default implementation using Bearer token and FlutterSecureStorage.
class DefaultAuthHooks extends AuthHooks {
  final FlutterSecureStorage _storage;

  static const String _tokenKey = 'escalated_auth_token';

  DefaultAuthHooks({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  @override
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  @override
  Future<void> setToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  @override
  Future<void> clearToken() async {
    await _storage.delete(key: _tokenKey);
  }

  @override
  Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  @override
  Future<Map<String, String>> getAuthHeaders() async {
    final token = await getToken();
    if (token == null || token.isEmpty) {
      return {};
    }
    return {'Authorization': 'Bearer $token'};
  }
}
