/// 서버 예외
class ServerException implements Exception {
  final String message;
  final int? statusCode;

  const ServerException({
    required this.message,
    this.statusCode,
  });

  @override
  String toString() => 'ServerException: $message (status: $statusCode)';
}

/// 네트워크 예외
class NetworkException implements Exception {
  final String message;

  const NetworkException([this.message = '네트워크 연결을 확인해주세요']);

  @override
  String toString() => 'NetworkException: $message';
}

/// 캐시 예외
class CacheException implements Exception {
  final String message;

  const CacheException([this.message = '캐시 오류가 발생했습니다']);

  @override
  String toString() => 'CacheException: $message';
}

/// 인증 예외
class AuthException implements Exception {
  final String message;

  const AuthException([this.message = '인증이 필요합니다']);

  @override
  String toString() => 'AuthException: $message';
}

/// 유효성 검사 예외
class ValidationException implements Exception {
  final String message;
  final Map<String, String>? fieldErrors;

  const ValidationException({
    required this.message,
    this.fieldErrors,
  });

  @override
  String toString() => 'ValidationException: $message';
}
