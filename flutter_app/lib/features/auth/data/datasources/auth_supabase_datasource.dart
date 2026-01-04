import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase_service.dart';
import '../../../core/errors/exceptions.dart';
import '../../auth/data/models/login_response_model.dart';
import '../../auth/data/models/user_model.dart';

/// Supabase를 사용한 인증 DataSource
///
/// 사용 예제:
/// ```dart
/// final dataSource = AuthSupabaseDataSource(SupabaseService.instance);
/// final response = await dataSource.login(
///   email: 'test@example.com',
///   password: 'password123',
/// );
/// ```
class AuthSupabaseDataSource {
  final SupabaseService _supabaseService;

  AuthSupabaseDataSource(this._supabaseService);

  /// 로그인
  Future<LoginResponseModel> login({
    required String email,
    required String password,
  }) async {
    try {
      // Supabase Auth로 로그인
      final response = await _supabaseService.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null || response.session == null) {
        throw const ServerException(message: 'Login failed: No user or session');
      }

      // 프로필 정보 가져오기
      final profileData = await _supabaseService.client
          .from('profiles')
          .select()
          .eq('id', response.user!.id)
          .single();

      // UserModel 생성
      final userModel = UserModel(
        id: response.user!.id,
        email: response.user!.email!,
        username: profileData['username'] ?? '',
        displayName: profileData['display_name'] ?? profileData['username'] ?? '',
        bio: profileData['bio'] ?? '',
        profileImageUrl: profileData['avatar_url'],
        followersCount: profileData['followers_count'] ?? 0,
        followingCount: profileData['following_count'] ?? 0,
        postsCount: profileData['posts_count'] ?? 0,
        createdAt: DateTime.parse(response.user!.createdAt),
      );

      return LoginResponseModel(
        accessToken: response.session!.accessToken,
        refreshToken: response.session!.refreshToken!,
        user: userModel,
      );
    } on AuthException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Login failed: $e');
    }
  }

  /// 회원가입
  Future<LoginResponseModel> register({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      // 1. 사용자명 중복 확인
      final existingUser = await _supabaseService.client
          .from('profiles')
          .select('username')
          .eq('username', username)
          .maybeSingle();

      if (existingUser != null) {
        throw const ServerException(message: 'Username already exists');
      }

      // 2. Supabase Auth로 회원가입
      final response = await _supabaseService.client.auth.signUp(
        email: email,
        password: password,
        data: {
          'username': username,
        },
      );

      if (response.user == null) {
        throw const ServerException(message: 'Registration failed');
      }

      // 3. 프로필 생성 (트리거로 자동 생성되거나 수동 생성)
      await _supabaseService.client.from('profiles').upsert({
        'id': response.user!.id,
        'username': username,
        'display_name': username,
        'bio': '',
        'created_at': DateTime.now().toIso8601String(),
      });

      // 4. 프로필 정보 다시 가져오기
      final profileData = await _supabaseService.client
          .from('profiles')
          .select()
          .eq('id', response.user!.id)
          .single();

      final userModel = UserModel(
        id: response.user!.id,
        email: response.user!.email!,
        username: profileData['username'],
        displayName: profileData['display_name'],
        bio: profileData['bio'] ?? '',
        profileImageUrl: profileData['avatar_url'],
        followersCount: 0,
        followingCount: 0,
        postsCount: 0,
        createdAt: DateTime.parse(response.user!.createdAt),
      );

      return LoginResponseModel(
        accessToken: response.session?.accessToken ?? '',
        refreshToken: response.session?.refreshToken ?? '',
        user: userModel,
      );
    } on AuthException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Registration failed: $e');
    }
  }

  /// 로그아웃
  Future<void> logout() async {
    try {
      await _supabaseService.signOut();
    } catch (e) {
      throw ServerException(message: 'Logout failed: $e');
    }
  }

  /// 토큰 갱신
  Future<LoginResponseModel> refreshToken() async {
    try {
      await _supabaseService.refreshSession();

      final session = _supabaseService.currentSession;
      final user = _supabaseService.currentUser;

      if (session == null || user == null) {
        throw const ServerException(message: 'No active session');
      }

      // 프로필 정보 가져오기
      final profileData = await _supabaseService.client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();

      final userModel = UserModel(
        id: user.id,
        email: user.email!,
        username: profileData['username'],
        displayName: profileData['display_name'],
        bio: profileData['bio'] ?? '',
        profileImageUrl: profileData['avatar_url'],
        followersCount: profileData['followers_count'] ?? 0,
        followingCount: profileData['following_count'] ?? 0,
        postsCount: profileData['posts_count'] ?? 0,
        createdAt: DateTime.parse(user.createdAt),
      );

      return LoginResponseModel(
        accessToken: session.accessToken,
        refreshToken: session.refreshToken!,
        user: userModel,
      );
    } catch (e) {
      throw ServerException(message: 'Token refresh failed: $e');
    }
  }

  /// 현재 사용자 정보 가져오기
  Future<UserModel> getCurrentUser() async {
    try {
      final user = _supabaseService.currentUser;

      if (user == null) {
        throw const ServerException(message: 'No authenticated user');
      }

      final profileData = await _supabaseService.client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();

      return UserModel(
        id: user.id,
        email: user.email!,
        username: profileData['username'],
        displayName: profileData['display_name'],
        bio: profileData['bio'] ?? '',
        profileImageUrl: profileData['avatar_url'],
        followersCount: profileData['followers_count'] ?? 0,
        followingCount: profileData['following_count'] ?? 0,
        postsCount: profileData['posts_count'] ?? 0,
        createdAt: DateTime.parse(user.createdAt),
      );
    } catch (e) {
      throw ServerException(message: 'Failed to get current user: $e');
    }
  }

  /// 비밀번호 재설정 이메일 발송
  Future<void> resetPassword({required String email}) async {
    try {
      await _supabaseService.client.auth.resetPasswordForEmail(email);
    } on AuthException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Password reset failed: $e');
    }
  }

  /// 비밀번호 업데이트
  Future<void> updatePassword({required String newPassword}) async {
    try {
      await _supabaseService.client.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } on AuthException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Password update failed: $e');
    }
  }
}
