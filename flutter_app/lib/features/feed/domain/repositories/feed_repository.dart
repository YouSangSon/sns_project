import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/post_entity.dart';

/// 피드 레포지토리 인터페이스
abstract class FeedRepository {
  /// 피드 게시물 목록 조회
  Future<Either<Failure, List<PostEntity>>> getFeed({
    int page = 1,
    int limit = 10,
  });

  /// 피드 새로고침
  Future<Either<Failure, List<PostEntity>>> refreshFeed();
}
