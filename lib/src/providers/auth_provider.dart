import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../services/api_client.dart';
import '../services/api_service.dart';
import '../services/auth_hooks.dart';

// Auth hooks provider — override this to swap in custom auth
final authHooksProvider = Provider<AuthHooks>((ref) {
  return DefaultAuthHooks(apiBaseUrl: 'http://localhost:8000/support/api/v1');
});

// API client provider
final apiClientProvider = Provider<ApiClient>((ref) {
  final authHooks = ref.watch(authHooksProvider);
  return ApiClient(
    authHooks: authHooks,
    baseUrl: 'http://localhost:8000/support/api/v1',
  );
});

// API service provider
final apiServiceProvider = Provider<ApiService>((ref) {
  final client = ref.watch(apiClientProvider);
  return ApiService(client);
});

// Auth state
enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final User? user;
  final String? error;
  final bool isLoading;

  const AuthState({
    this.status = AuthStatus.unknown,
    this.user,
    this.error,
    this.isLoading = false,
  });

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? error,
    bool? isLoading,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: error,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthHooks _authHooks;
  final ApiService _apiService;

  AuthNotifier(this._authHooks, this._apiService)
      : super(const AuthState()) {
    checkAuth();
  }

  Future<void> checkAuth() async {
    state = state.copyWith(isLoading: true);
    try {
      final headers = await _authHooks.getAuthHeaders();
      if (headers.isNotEmpty) {
        final user = await _apiService.getProfile();
        state = AuthState(
          status: AuthStatus.authenticated,
          user: user,
        );
      } else {
        state = const AuthState(status: AuthStatus.unauthenticated);
      }
    } catch (e) {
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _authHooks.onLogin(email, password);

      final user = await _apiService.getProfile();
      state = AuthState(
        status: AuthStatus.authenticated,
        user: user,
      );
    } on DioException catch (e) {
      final message = e.response?.data?['message'] as String? ??
          'Login failed. Please check your credentials.';
      state = state.copyWith(
        isLoading: false,
        error: message,
        status: AuthStatus.unauthenticated,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'An unexpected error occurred.',
        status: AuthStatus.unauthenticated,
      );
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _authHooks.onRegister({
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      });

      final user = await _apiService.getProfile();
      state = AuthState(
        status: AuthStatus.authenticated,
        user: user,
      );
    } on DioException catch (e) {
      final message = e.response?.data?['message'] as String? ??
          'Registration failed. Please try again.';
      state = state.copyWith(
        isLoading: false,
        error: message,
        status: AuthStatus.unauthenticated,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'An unexpected error occurred.',
        status: AuthStatus.unauthenticated,
      );
    }
  }

  Future<void> logout() async {
    try {
      await _apiService.logout();
    } catch (_) {
      // Ignore errors on logout
    }
    await _authHooks.onLogout();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  Future<void> updateProfile({String? name, String? email}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _apiService.updateProfile(name: name, email: email);
      state = state.copyWith(user: user, isLoading: false);
    } on DioException catch (e) {
      final message = e.response?.data?['message'] as String? ??
          'Failed to update profile.';
      state = state.copyWith(isLoading: false, error: message);
    } catch (e) {
      state = state.copyWith(
          isLoading: false, error: 'An unexpected error occurred.');
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authHooks = ref.watch(authHooksProvider);
  final apiService = ref.watch(apiServiceProvider);
  return AuthNotifier(authHooks, apiService);
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).status == AuthStatus.authenticated;
});
