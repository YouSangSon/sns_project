import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/auth_tokens.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// 회원가입 유즈케이스
class RegisterUseCase {
  final AuthRepository _repository;

  RegisterUseCase(this._repository);

  Future<Either<Failure, (UserEntity, AuthTokens)>> call({
    required String email,
    required String password,
    required String username,
    required String name,
  }) {
    return _repository.register(
      email: email,
      password: password,
      username: username,
      name: name,
    );
  }
}
