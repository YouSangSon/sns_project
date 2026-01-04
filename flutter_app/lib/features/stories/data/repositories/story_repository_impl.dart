import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/story_entity.dart';
import '../../domain/repositories/story_repository.dart';
import '../datasources/story_remote_datasource.dart';

/// 스토리 레포지토리 구현
class StoryRepositoryImpl implements StoryRepository {
  final StoryRemoteDataSource _remoteDataSource;

  StoryRepositoryImpl({required StoryRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, List<StoryGroupEntity>>> getStoryFeed() async {
    try {
      final groups = await _remoteDataSource.getStoryFeed();
      return Right(groups.map((g) => g.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(Failure.server(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(Failure.network(message: e.message));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<StoryEntity>>> getUserStories(
      String userId) async {
    try {
      final stories = await _remoteDataSource.getUserStories(userId);
      return Right(stories.map((s) => s.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(Failure.server(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(Failure.network(message: e.message));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, StoryEntity>> createStory({
    required String mediaPath,
    required StoryType type,
  }) async {
    try {
      final story = await _remoteDataSource.createStory(
        mediaPath: mediaPath,
        type: type,
      );
      return Right(story.toEntity());
    } on ServerException catch (e) {
      return Left(Failure.server(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(Failure.network(message: e.message));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteStory(String id) async {
    try {
      await _remoteDataSource.deleteStory(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(Failure.server(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(Failure.network(message: e.message));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> viewStory(String id) async {
    try {
      await _remoteDataSource.viewStory(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(Failure.server(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(Failure.network(message: e.message));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }
}
