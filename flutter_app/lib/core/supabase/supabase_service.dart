import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/env_config.dart';

/// Supabase 클라이언트 싱글톤
/// 앱 전체에서 사용되는 Supabase 인스턴스를 제공합니다.
class SupabaseService {
  SupabaseService._();

  static SupabaseService? _instance;
  static SupabaseService get instance {
    _instance ??= SupabaseService._();
    return _instance!;
  }

  /// Supabase 클라이언트 인스턴스
  SupabaseClient get client => Supabase.instance.client;

  /// 초기화 여부
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  /// Supabase 초기화
  /// main() 함수에서 호출해야 합니다.
  Future<void> initialize() async {
    if (_isInitialized) {
      print('⚠️ Supabase already initialized');
      return;
    }

    try {
      final env = EnvConfig.instance;

      await Supabase.initialize(
        url: env.supabaseUrl,
        anonKey: env.supabaseAnonKey,
        debug: env.isDevelopment,
        authOptions: FlutterAuthClientOptions(
          authFlowType: AuthFlowType.pkce,
          // Deep link scheme (앱 이름으로 변경)
          // 예: com.yourcompany.snsapp://
        ),
        storageOptions: const StorageClientOptions(
          retryAttempts: 3,
        ),
      );

      _isInitialized = true;

      print('✅ Supabase initialized');
      print('   URL: ${env.supabaseUrl}');
      print('   Auth: ${client.auth.currentUser?.email ?? "Not authenticated"}');
    } catch (e, stackTrace) {
      print('❌ Failed to initialize Supabase: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// 현재 로그인된 사용자
  User? get currentUser => client.auth.currentUser;

  /// 로그인 여부
  bool get isAuthenticated => currentUser != null;

  /// 현재 세션
  Session? get currentSession => client.auth.currentSession;

  /// 액세스 토큰
  String? get accessToken => currentSession?.accessToken;

  /// 리프레시 토큰
  String? get refreshToken => currentSession?.refreshToken;

  /// Auth 상태 변경 스트림
  Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;

  /// 로그아웃
  Future<void> signOut() async {
    await client.auth.signOut();
  }

  /// Storage - 파일 업로드
  Future<String> uploadFile({
    required String bucket,
    required String path,
    required dynamic file,
    Map<String, String>? metadata,
  }) async {
    final response = await client.storage.from(bucket).upload(
          path,
          file,
          fileOptions: FileOptions(
            contentType: metadata?['contentType'],
          ),
        );

    return response;
  }

  /// Storage - 파일 다운로드 URL 가져오기
  String getPublicUrl({
    required String bucket,
    required String path,
  }) {
    return client.storage.from(bucket).getPublicUrl(path);
  }

  /// Storage - 파일 삭제
  Future<void> deleteFile({
    required String bucket,
    required String path,
  }) async {
    await client.storage.from(bucket).remove([path]);
  }

  /// Realtime - 채널 구독
  RealtimeChannel subscribe(String channelName) {
    return client.channel(channelName);
  }

  /// Database - 쿼리 빌더
  SupabaseQueryBuilder from(String table) {
    return client.from(table);
  }

  /// RPC (Remote Procedure Call) 호출
  Future<T> rpc<T>(
    String functionName, {
    Map<String, dynamic>? params,
  }) async {
    return await client.rpc(functionName, params: params);
  }

  /// 연결 상태 확인
  Future<bool> checkConnection() async {
    try {
      // 간단한 쿼리로 연결 테스트
      await client.from('profiles').select('id').limit(1);
      return true;
    } catch (e) {
      print('Supabase connection check failed: $e');
      return false;
    }
  }

  /// 세션 갱신
  Future<void> refreshSession() async {
    try {
      await client.auth.refreshSession();
      print('✅ Session refreshed successfully');
    } catch (e) {
      print('❌ Failed to refresh session: $e');
      rethrow;
    }
  }

  /// 디버그 정보 출력
  void printDebugInfo() {
    print('=== Supabase Debug Info ===');
    print('Initialized: $_isInitialized');
    print('URL: ${EnvConfig.instance.supabaseUrl}');
    print('Authenticated: $isAuthenticated');
    print('User: ${currentUser?.email ?? "None"}');
    print('User ID: ${currentUser?.id ?? "None"}');
    print('Session expires at: ${currentSession?.expiresAt}');
    print('==========================');
  }
}

/// 편의를 위한 전역 인스턴스
final supabase = SupabaseService.instance.client;
