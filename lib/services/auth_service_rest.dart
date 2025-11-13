import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_service.dart';

/// REST API Authentication Service (JWT-based)
/// Replaces Firebase Authentication
class AuthServiceRest {
  final ApiService _api = ApiService();
  final _storage = const FlutterSecureStorage();

  // Storage keys
  static const String _keyAuthToken = 'auth_token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyUserId = 'user_id';
  static const String _keyUserEmail = 'user_email';

  /// Register new user
  Future<AuthResult> register({
    required String email,
    required String password,
    required String username,
    required String fullName,
  }) async {
    try {
      final response = await _api.post(
        '/auth/register',
        data: {
          'email': email,
          'password': password,
          'username': username,
          'fullName': fullName,
        },
      );

      final userId = response.data['userId'] as String;
      final accessToken = response.data['accessToken'] as String;
      final refreshToken = response.data['refreshToken'] as String;

      // Store tokens and user info
      await _saveAuthData(
        userId: userId,
        email: email,
        accessToken: accessToken,
        refreshToken: refreshToken,
      );

      return AuthResult(
        success: true,
        userId: userId,
        email: email,
      );
    } catch (e) {
      print('Error registering user: $e');
      return AuthResult(
        success: false,
        error: _extractErrorMessage(e),
      );
    }
  }

  /// Login with email and password
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _api.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      final userId = response.data['userId'] as String;
      final accessToken = response.data['accessToken'] as String;
      final refreshToken = response.data['refreshToken'] as String;

      // Store tokens and user info
      await _saveAuthData(
        userId: userId,
        email: email,
        accessToken: accessToken,
        refreshToken: refreshToken,
      );

      return AuthResult(
        success: true,
        userId: userId,
        email: email,
      );
    } catch (e) {
      print('Error logging in: $e');
      return AuthResult(
        success: false,
        error: _extractErrorMessage(e),
      );
    }
  }

  /// Login with Google (OAuth)
  /// Note: Requires backend OAuth implementation
  Future<AuthResult> loginWithGoogle() async {
    try {
      // This would typically involve:
      // 1. Google Sign In to get OAuth token
      // 2. Send OAuth token to backend
      // 3. Backend verifies with Google and returns JWT

      // For now, return not implemented
      return AuthResult(
        success: false,
        error: 'Google Sign In not implemented yet',
      );
    } catch (e) {
      print('Error with Google login: $e');
      return AuthResult(
        success: false,
        error: _extractErrorMessage(e),
      );
    }
  }

  /// Logout current user
  Future<void> logout() async {
    try {
      // Optional: Call backend logout endpoint
      await _api.post('/auth/logout');
    } catch (e) {
      print('Error calling logout endpoint: $e');
    } finally {
      // Always clear local data
      await _clearAuthData();
    }
  }

  /// Get current user ID
  Future<String?> getCurrentUserId() async {
    return await _storage.read(key: _keyUserId);
  }

  /// Get current user email
  Future<String?> getCurrentUserEmail() async {
    return await _storage.read(key: _keyUserEmail);
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: _keyAuthToken);
    return token != null && token.isNotEmpty;
  }

  /// Get current auth token
  Future<String?> getAuthToken() async {
    return await _storage.read(key: _keyAuthToken);
  }

  /// Get refresh token
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _keyRefreshToken);
  }

  /// Refresh access token
  Future<bool> refreshAccessToken() async {
    try {
      final refreshToken = await getRefreshToken();

      if (refreshToken == null) {
        return false;
      }

      final response = await _api.post(
        '/auth/refresh',
        data: {
          'refreshToken': refreshToken,
        },
      );

      final newAccessToken = response.data['accessToken'] as String;
      final newRefreshToken = response.data['refreshToken'] as String;

      // Update stored tokens
      await _storage.write(key: _keyAuthToken, value: newAccessToken);
      await _storage.write(key: _keyRefreshToken, value: newRefreshToken);

      return true;
    } catch (e) {
      print('Error refreshing token: $e');
      return false;
    }
  }

  /// Change password
  Future<AuthResult> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final userId = await getCurrentUserId();

      if (userId == null) {
        return AuthResult(
          success: false,
          error: '로그인이 필요합니다',
        );
      }

      await _api.put(
        '/users/$userId/password',
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
      );

      return AuthResult(success: true);
    } catch (e) {
      print('Error changing password: $e');
      return AuthResult(
        success: false,
        error: _extractErrorMessage(e),
      );
    }
  }

  /// Reset password (request reset email)
  Future<AuthResult> requestPasswordReset({
    required String email,
  }) async {
    try {
      await _api.post(
        '/auth/password-reset',
        data: {
          'email': email,
        },
      );

      return AuthResult(
        success: true,
        message: '비밀번호 재설정 이메일이 전송되었습니다',
      );
    } catch (e) {
      print('Error requesting password reset: $e');
      return AuthResult(
        success: false,
        error: _extractErrorMessage(e),
      );
    }
  }

  /// Verify password reset token and set new password
  Future<AuthResult> resetPassword({
    required String resetToken,
    required String newPassword,
  }) async {
    try {
      await _api.post(
        '/auth/password-reset/confirm',
        data: {
          'token': resetToken,
          'newPassword': newPassword,
        },
      );

      return AuthResult(
        success: true,
        message: '비밀번호가 재설정되었습니다',
      );
    } catch (e) {
      print('Error resetting password: $e');
      return AuthResult(
        success: false,
        error: _extractErrorMessage(e),
      );
    }
  }

  /// Verify email address
  Future<AuthResult> verifyEmail({
    required String verificationToken,
  }) async {
    try {
      await _api.post(
        '/auth/verify-email',
        data: {
          'token': verificationToken,
        },
      );

      return AuthResult(
        success: true,
        message: '이메일이 인증되었습니다',
      );
    } catch (e) {
      print('Error verifying email: $e');
      return AuthResult(
        success: false,
        error: _extractErrorMessage(e),
      );
    }
  }

  /// Resend verification email
  Future<AuthResult> resendVerificationEmail() async {
    try {
      final email = await getCurrentUserEmail();

      if (email == null) {
        return AuthResult(
          success: false,
          error: '로그인이 필요합니다',
        );
      }

      await _api.post(
        '/auth/verify-email/resend',
        data: {
          'email': email,
        },
      );

      return AuthResult(
        success: true,
        message: '인증 이메일이 재전송되었습니다',
      );
    } catch (e) {
      print('Error resending verification email: $e');
      return AuthResult(
        success: false,
        error: _extractErrorMessage(e),
      );
    }
  }

  /// Delete account
  Future<AuthResult> deleteAccount({
    required String password,
  }) async {
    try {
      final userId = await getCurrentUserId();

      if (userId == null) {
        return AuthResult(
          success: false,
          error: '로그인이 필요합니다',
        );
      }

      await _api.delete(
        '/users/$userId',
        data: {
          'password': password,
        },
      );

      // Clear local data
      await _clearAuthData();

      return AuthResult(
        success: true,
        message: '계정이 삭제되었습니다',
      );
    } catch (e) {
      print('Error deleting account: $e');
      return AuthResult(
        success: false,
        error: _extractErrorMessage(e),
      );
    }
  }

  // ========== PRIVATE HELPER METHODS ==========

  /// Save authentication data to secure storage
  Future<void> _saveAuthData({
    required String userId,
    required String email,
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _keyUserId, value: userId);
    await _storage.write(key: _keyUserEmail, value: email);
    await _storage.write(key: _keyAuthToken, value: accessToken);
    await _storage.write(key: _keyRefreshToken, value: refreshToken);
  }

  /// Clear all authentication data
  Future<void> _clearAuthData() async {
    await _storage.delete(key: _keyUserId);
    await _storage.delete(key: _keyUserEmail);
    await _storage.delete(key: _keyAuthToken);
    await _storage.delete(key: _keyRefreshToken);
  }

  /// Extract error message from exception
  String _extractErrorMessage(dynamic error) {
    if (error is Map && error.containsKey('message')) {
      return error['message'].toString();
    }
    return error.toString();
  }
}

/// Authentication Result
class AuthResult {
  final bool success;
  final String? userId;
  final String? email;
  final String? error;
  final String? message;

  AuthResult({
    required this.success,
    this.userId,
    this.email,
    this.error,
    this.message,
  });

  @override
  String toString() {
    if (success) {
      return 'AuthResult(success: true, userId: $userId, email: $email, message: $message)';
    } else {
      return 'AuthResult(success: false, error: $error)';
    }
  }
}

/// Example usage:
///
/// // Register
/// final authService = AuthServiceRest();
/// final result = await authService.register(
///   email: 'user@example.com',
///   password: 'password123',
///   username: 'username',
///   fullName: 'John Doe',
/// );
///
/// if (result.success) {
///   print('Registration successful: ${result.userId}');
/// } else {
///   print('Registration failed: ${result.error}');
/// }
///
/// // Login
/// final loginResult = await authService.login(
///   email: 'user@example.com',
///   password: 'password123',
/// );
///
/// // Check login status
/// final isLoggedIn = await authService.isLoggedIn();
///
/// // Get current user
/// final userId = await authService.getCurrentUserId();
///
/// // Logout
/// await authService.logout();
