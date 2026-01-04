import 'dart:developer' as developer;
import 'package:dio/dio.dart';

/// 로깅 인터셉터 - 요청/응답 로깅
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    developer.log(
      '┌─────────────────────────────────────────────────────────',
      name: 'HTTP',
    );
    developer.log(
      '│ 📤 ${options.method} ${options.uri}',
      name: 'HTTP',
    );
    if (options.headers.isNotEmpty) {
      developer.log(
        '│ Headers: ${_formatHeaders(options.headers)}',
        name: 'HTTP',
      );
    }
    if (options.data != null) {
      developer.log(
        '│ Body: ${options.data}',
        name: 'HTTP',
      );
    }
    developer.log(
      '└─────────────────────────────────────────────────────────',
      name: 'HTTP',
    );

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    developer.log(
      '┌─────────────────────────────────────────────────────────',
      name: 'HTTP',
    );
    developer.log(
      '│ 📥 ${response.statusCode} ${response.requestOptions.uri}',
      name: 'HTTP',
    );
    developer.log(
      '│ Response: ${_truncate(response.data.toString(), 500)}',
      name: 'HTTP',
    );
    developer.log(
      '└─────────────────────────────────────────────────────────',
      name: 'HTTP',
    );

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    developer.log(
      '┌─────────────────────────────────────────────────────────',
      name: 'HTTP',
    );
    developer.log(
      '│ ❌ ${err.response?.statusCode ?? 'ERROR'} ${err.requestOptions.uri}',
      name: 'HTTP',
    );
    developer.log(
      '│ Error: ${err.message}',
      name: 'HTTP',
    );
    if (err.response?.data != null) {
      developer.log(
        '│ Response: ${err.response?.data}',
        name: 'HTTP',
      );
    }
    developer.log(
      '└─────────────────────────────────────────────────────────',
      name: 'HTTP',
    );

    handler.next(err);
  }

  String _formatHeaders(Map<String, dynamic> headers) {
    final filtered = Map<String, dynamic>.from(headers);
    // 민감한 헤더 마스킹
    if (filtered.containsKey('Authorization')) {
      filtered['Authorization'] = '***';
    }
    return filtered.toString();
  }

  String _truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }
}
