import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/auth_tokens.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// 로그인 유즈케이스
class LoginUseCase {
  final AuthRepository _repository;

  LoginUseCase(this._repository);

  Future<Either<Failure, (UserEntity, AuthTokens)>> call({
    required String email,
    required String password,
  }) {
    return _repository.login(email: email, password: password);
  }
}
