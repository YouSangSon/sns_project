import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// API Service - REST API 서버와 통신
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  late final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // API 서버 기본 URL
  static const String _baseUrl = 'https://your-api-server.com/api/v1';

  // Timeout 설정
  static const Duration _connectTimeout = Duration(seconds: 30);
  static const Duration _receiveTimeout = Duration(seconds: 30);

  /// Initialize API Service
  void initialize() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: _connectTimeout,
        receiveTimeout: _receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Interceptors 추가
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: _onRequest,
        onResponse: _onResponse,
        onError: _onError,
      ),
    );
  }

  /// Request Interceptor - JWT 토큰 자동 추가
  Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // JWT 토큰 가져오기
    final token = await _storage.read(key: 'auth_token');

    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    print('🌐 API Request: ${options.method} ${options.path}');
    handler.next(options);
  }

  /// Response Interceptor
  void _onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) {
    print('✅ API Response: ${response.statusCode} ${response.requestOptions.path}');
    handler.next(response);
  }

  /// Error Interceptor
  Future<void> _onError(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    print('❌ API Error: ${error.response?.statusCode} ${error.message}');

    // 401 Unauthorized - 토큰 만료
    if (error.response?.statusCode == 401) {
      // 토큰 갱신 시도
      final refreshed = await _refreshToken();

      if (refreshed) {
        // 원래 요청 재시도
        final options = error.requestOptions;
        final token = await _storage.read(key: 'auth_token');
        options.headers['Authorization'] = 'Bearer $token';

        try {
          final response = await _dio.fetch(options);
          return handler.resolve(response);
        } catch (e) {
          return handler.reject(error);
        }
      }
    }

    handler.next(error);
  }

  /// Refresh JWT Token
  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _storage.read(key: 'refresh_token');

      if (refreshToken == null) return false;

      final response = await _dio.post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200) {
        final newToken = response.data['accessToken'];
        final newRefreshToken = response.data['refreshToken'];

        await _storage.write(key: 'auth_token', value: newToken);
        await _storage.write(key: 'refresh_token', value: newRefreshToken);

        return true;
      }

      return false;
    } catch (e) {
      print('Token refresh failed: $e');
      return false;
    }
  }

  /// GET Request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// POST Request
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// PUT Request
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// DELETE Request
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// PATCH Request
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Upload File
  Future<Response> uploadFile(
    String path,
    String filePath, {
    String fieldName = 'file',
    Map<String, dynamic>? data,
    ProgressCallback? onProgress,
  }) async {
    try {
      final formData = FormData.fromMap({
        fieldName: await MultipartFile.fromFile(filePath),
        ...?data,
      });

      return await _dio.post(
        path,
        data: formData,
        onSendProgress: onProgress,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Download File
  Future<Response> downloadFile(
    String url,
    String savePath, {
    ProgressCallback? onProgress,
  }) async {
    try {
      return await _dio.download(
        url,
        savePath,
        onReceiveProgress: onProgress,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Clear Auth Tokens
  Future<void> clearTokens() async {
    await _storage.delete(key: 'auth_token');
    await _storage.delete(key: 'refresh_token');
  }
}
