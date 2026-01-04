import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../repositories/profile_repository.dart';

/// 팔로우 유즈케이스
class FollowUseCase {
  final ProfileRepository _repository;

  FollowUseCase(this._repository);

  Future<Either<Failure, UserEntity>> call(String userId) {
    return _repository.follow(userId);
  }
}

/// 언팔로우 유즈케이스
class UnfollowUseCase {
  final ProfileRepository _repository;

  UnfollowUseCase(this._repository);

  Future<Either<Failure, UserEntity>> call(String userId) {
    return _repository.unfollow(userId);
  }
}
