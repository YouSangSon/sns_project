import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/post_entity.dart';
import '../repositories/feed_repository.dart';

/// 피드 조회 유즈케이스
class GetFeedUseCase {
  final FeedRepository _repository;

  GetFeedUseCase(this._repository);

  Future<Either<Failure, List<PostEntity>>> call({
    int page = 1,
    int limit = 10,
  }) {
    return _repository.getFeed(page: page, limit: limit);
  }
}
