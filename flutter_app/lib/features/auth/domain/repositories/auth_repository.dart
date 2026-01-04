import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/auth_tokens.dart';
import '../entities/user_entity.dart';

/// 인증 레포지토리 인터페이스
abstract class AuthRepository {
  /// 로그인
  Future<Either<Failure, (UserEntity, AuthTokens)>> login({
    required String email,
    required String password,
  });

  /// 회원가입
  Future<Either<Failure, (UserEntity, AuthTokens)>> register({
    required String email,
    required String password,
    required String username,
    required String name,
  });

  /// 로그아웃
  Future<Either<Failure, void>> logout();

  /// 토큰 갱신
  Future<Either<Failure, AuthTokens>> refreshToken();

  /// 현재 사용자 조회
  Future<Either<Failure, UserEntity>> getCurrentUser();

  /// 로그인 상태 확인
  Future<bool> isLoggedIn();

  /// 저장된 토큰 조회
  Future<AuthTokens?> getStoredTokens();
}
