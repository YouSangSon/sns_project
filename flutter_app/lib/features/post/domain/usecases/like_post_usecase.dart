import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../feed/domain/entities/post_entity.dart';
import '../repositories/post_repository.dart';

/// 게시물 좋아요 유즈케이스
class LikePostUseCase {
  final PostRepository _repository;

  LikePostUseCase(this._repository);

  Future<Either<Failure, PostEntity>> call(String postId) {
    return _repository.likePost(postId);
  }
}

/// 게시물 좋아요 취소 유즈케이스
class UnlikePostUseCase {
  final PostRepository _repository;

  UnlikePostUseCase(this._repository);

  Future<Either<Failure, PostEntity>> call(String postId) {
    return _repository.unlikePost(postId);
  }
}
