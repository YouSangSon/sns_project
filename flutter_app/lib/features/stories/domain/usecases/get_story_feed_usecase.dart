import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/story_entity.dart';
import '../repositories/story_repository.dart';

/// 스토리 피드 조회 유즈케이스
class GetStoryFeedUseCase {
  final StoryRepository _repository;

  GetStoryFeedUseCase(this._repository);

  Future<Either<Failure, List<StoryGroupEntity>>> call() {
    return _repository.getStoryFeed();
  }
}
