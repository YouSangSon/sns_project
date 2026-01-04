import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../feed/domain/entities/post_entity.dart';
import '../repositories/post_repository.dart';

/// 게시물 생성 유즈케이스
class CreatePostUseCase {
  final PostRepository _repository;

  CreatePostUseCase(this._repository);

  Future<Either<Failure, PostEntity>> call({
    String? content,
    List<String>? imagePaths,
    String? location,
  }) {
    return _repository.createPost(
      content: content,
      imagePaths: imagePaths,
      location: location,
    );
  }
}
