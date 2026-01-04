import 'package:freezed_annotation/freezed_annotation.dart';

part 'failures.freezed.dart';

/// 앱에서 발생할 수 있는 실패 유형 정의
@freezed
class Failure with _$Failure {
  const Failure._();

  /// 서버 오류
  const factory Failure.server({
    required String message,
    int? statusCode,
  }) = ServerFailure;

  /// 네트워크 연결 오류
  const factory Failure.network({
    @Default('네트워크 연결을 확인해주세요') String message,
  }) = NetworkFailure;

  /// 캐시 오류
  const factory Failure.cache({
    @Default('캐시 오류가 발생했습니다') String message,
  }) = CacheFailure;

  /// 인증 오류
  const factory Failure.auth({
    @Default('인증이 필요합니다') String message,
  }) = AuthFailure;

  /// 유효성 검사 오류
  const factory Failure.validation({
    required String message,
    Map<String, String>? fieldErrors,
  }) = ValidationFailure;

  /// 알 수 없는 오류
  const factory Failure.unknown({
    @Default('알 수 없는 오류가 발생했습니다') String message,
  }) = UnknownFailure;

  /// 오류 메시지 반환
  String get errorMessage => when(
        server: (message, _) => message,
        network: (message) => message,
        cache: (message) => message,
        auth: (message) => message,
        validation: (message, _) => message,
        unknown: (message) => message,
      );
}
