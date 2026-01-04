import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/post_entity.dart';
import '../../domain/repositories/feed_repository.dart';
import '../datasources/feed_remote_datasource.dart';

/// 피드 레포지토리 구현
class FeedRepositoryImpl implements FeedRepository {
  final FeedRemoteDataSource _remoteDataSource;

  FeedRepositoryImpl({required FeedRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, List<PostEntity>>> getFeed({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _remoteDataSource.getFeed(page: page, limit: limit);
      final posts = response.posts.map((p) => p.toEntity()).toList();
      return Right(posts);
    } on ServerException catch (e) {
      return Left(Failure.server(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(Failure.network(message: e.message));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PostEntity>>> refreshFeed() async {
    return getFeed(page: 1, limit: 10);
  }
}
