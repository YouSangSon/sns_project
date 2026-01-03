import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import '../../../../core/constants/app_config.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../shared/models/user_model.dart';

// Auth State
class AuthState {
  final User? user;
  final String? token;
  final bool isAuthenticated;
  final bool isLoading;
  final String? errorMessage;

  const AuthState({
    this.user,
    this.token,
    this.isAuthenticated = false,
    this.isLoading = true,
    this.errorMessage,
  });

  AuthState copyWith({
    User? user,
    String? token,
    bool? isAuthenticated,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AuthState(
      user: user ?? this.user,
      token: token ?? this.token,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

// Auth Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final ApiService _apiService;
  final FlutterSecureStorage _storage;

  AuthNotifier(this._apiService, this._storage) : super(const AuthState()) {
    loadAuth();
  }

  Future<void> loadAuth() async {
    try {
      // Dev mode - auto login
      if (AppConfig.isDev) {
        state = AuthState(
          user: User.devUser,
          token: 'dev-token-mock',
          isAuthenticated: true,
          isLoading: false,
        );
        return;
      }

      final token = await _storage.read(key: AppConfig.authTokenKey);
      final userData = await _storage.read(key: AppConfig.userDataKey);

      if (token != null && userData != null) {
        final user = User.fromJson(jsonDecode(userData));
        state = AuthState(
          user: user,
          token: token,
          isAuthenticated: true,
          isLoading: false,
        );
      } else {
        state = const AuthState(isLoading: false);
      }
    } catch (e) {
      state = const AuthState(isLoading: false);
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      // Dev mode
      if (AppConfig.isDev) {
        await Future.delayed(const Duration(seconds: 1));
        state = AuthState(
          user: User.devUser,
          token: 'dev-token-mock',
          isAuthenticated: true,
          isLoading: false,
        );
        return true;
      }

      final response = await _apiService.post(
        ApiEndpoints.login,
        data: {'email': email, 'password': password},
      );

      final user = User.fromJson(response.data['user']);
      final token = response.data['token'] as String;
      final refreshToken = response.data['refreshToken'] as String?;

      await _storage.write(key: AppConfig.authTokenKey, value: token);
      await _storage.write(key: AppConfig.userDataKey, value: jsonEncode(user.toJson()));
      if (refreshToken != null) {
        await _storage.write(key: AppConfig.refreshTokenKey, value: refreshToken);
      }

      state = AuthState(
        user: user,
        token: token,
        isAuthenticated: true,
        isLoading: false,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Login failed. Please check your credentials.',
      );
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String username,
    required String displayName,
    required String password,
  }) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      // Dev mode
      if (AppConfig.isDev) {
        await Future.delayed(const Duration(seconds: 1));
        final user = User.devUser.copyWith(
          email: email,
          username: username,
          displayName: displayName,
        );
        state = AuthState(
          user: user,
          token: 'dev-token-mock',
          isAuthenticated: true,
          isLoading: false,
        );
        return true;
      }

      final response = await _apiService.post(
        ApiEndpoints.register,
        data: {
          'email': email,
          'username': username,
          'displayName': displayName,
          'password': password,
        },
      );

      final user = User.fromJson(response.data['user']);
      final token = response.data['token'] as String;

      await _storage.write(key: AppConfig.authTokenKey, value: token);
      await _storage.write(key: AppConfig.userDataKey, value: jsonEncode(user.toJson()));

      state = AuthState(
        user: user,
        token: token,
        isAuthenticated: true,
        isLoading: false,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Registration failed. Please try again.',
      );
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _storage.deleteAll();
      state = const AuthState(isLoading: false);
    } catch (e) {
      state = const AuthState(isLoading: false);
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

// Providers
final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  final storage = ref.watch(secureStorageProvider);
  return AuthNotifier(apiService, storage);
});

final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).user;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authStateProvider).isAuthenticated;
});
