import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/story_entity.dart';

/// 스토리 레포지토리 인터페이스
abstract class StoryRepository {
  /// 스토리 피드 조회 (팔로잉 사용자들의 스토리)
  Future<Either<Failure, List<StoryGroupEntity>>> getStoryFeed();

  /// 사용자 스토리 조회
  Future<Either<Failure, List<StoryEntity>>> getUserStories(String userId);

  /// 스토리 생성
  Future<Either<Failure, StoryEntity>> createStory({
    required String mediaPath,
    required StoryType type,
  });

  /// 스토리 삭제
  Future<Either<Failure, void>> deleteStory(String id);

  /// 스토리 조회 기록
  Future<Either<Failure, void>> viewStory(String id);
}
