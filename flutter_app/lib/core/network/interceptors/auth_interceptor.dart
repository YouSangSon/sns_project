import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../constants/app_config.dart';

/// 인증 인터셉터 - 요청에 토큰 추가 및 토큰 갱신 처리
class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // 토큰이 필요없는 엔드포인트 목록
    final publicEndpoints = [
      '/auth/login',
      '/auth/register',
    ];

    final isPublicEndpoint = publicEndpoints.any(
      (endpoint) => options.path.contains(endpoint),
    );

    if (!isPublicEndpoint) {
      final token = await _storage.read(key: AppConfig.accessTokenKey);
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }

    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      // 토큰 갱신 시도
      final refreshed = await _refreshToken();
      if (refreshed) {
        // 원래 요청 재시도
        try {
          final token = await _storage.read(key: AppConfig.accessTokenKey);
          final options = err.requestOptions;
          options.headers['Authorization'] = 'Bearer $token';

          final dio = Dio();
          final response = await dio.fetch(options);
          return handler.resolve(response);
        } catch (e) {
          // 재시도 실패
        }
      }

      // 토큰 갱신 실패 - 로그아웃 처리 필요
      await _clearTokens();
    }

    handler.next(err);
  }

  /// 토큰 갱신
  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _storage.read(key: AppConfig.refreshTokenKey);
      if (refreshToken == null) return false;

      final dio = Dio();
      final response = await dio.post(
        '${AppConfig.baseUrl}/auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        await _storage.write(
          key: AppConfig.accessTokenKey,
          value: data['accessToken'] as String,
        );
        if (data['refreshToken'] != null) {
          await _storage.write(
            key: AppConfig.refreshTokenKey,
            value: data['refreshToken'] as String,
          );
        }
        return true;
      }
    } catch (e) {
      // 갱신 실패
    }
    return false;
  }

  /// 토큰 삭제
  Future<void> _clearTokens() async {
    await _storage.delete(key: AppConfig.accessTokenKey);
    await _storage.delete(key: AppConfig.refreshTokenKey);
    await _storage.delete(key: AppConfig.userDataKey);
  }
}
