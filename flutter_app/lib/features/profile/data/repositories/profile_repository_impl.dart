import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../feed/domain/entities/post_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';

/// 프로필 레포지토리 구현
class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource _remoteDataSource;

  ProfileRepositoryImpl({required ProfileRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, UserEntity>> getProfile(String userId) async {
    try {
      final user = await _remoteDataSource.getProfile(userId);
      return Right(user.toEntity());
    } on ServerException catch (e) {
      return Left(Failure.server(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(Failure.network(message: e.message));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> updateProfile({
    String? name,
    String? bio,
    String? profileImagePath,
  }) async {
    try {
      final user = await _remoteDataSource.updateProfile(
        name: name,
        bio: bio,
        profileImagePath: profileImagePath,
      );
      return Right(user.toEntity());
    } on ServerException catch (e) {
      return Left(Failure.server(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(Failure.network(message: e.message));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PostEntity>>> getUserPosts(
    String userId, {
    int page = 1,
    int limit = 12,
  }) async {
    try {
      final posts = await _remoteDataSource.getUserPosts(
        userId,
        page: page,
        limit: limit,
      );
      return Right(posts.map((p) => p.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(Failure.server(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(Failure.network(message: e.message));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> follow(String userId) async {
    try {
      final user = await _remoteDataSource.follow(userId);
      return Right(user.toEntity());
    } on ServerException catch (e) {
      return Left(Failure.server(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(Failure.network(message: e.message));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> unfollow(String userId) async {
    try {
      final user = await _remoteDataSource.unfollow(userId);
      return Right(user.toEntity());
    } on ServerException catch (e) {
      return Left(Failure.server(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(Failure.network(message: e.message));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<UserEntity>>> getFollowers(
    String userId, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final users = await _remoteDataSource.getFollowers(
        userId,
        page: page,
        limit: limit,
      );
      return Right(users.map((u) => u.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(Failure.server(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(Failure.network(message: e.message));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<UserEntity>>> getFollowing(
    String userId, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final users = await _remoteDataSource.getFollowing(
        userId,
        page: page,
        limit: limit,
      );
      return Right(users.map((u) => u.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(Failure.server(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(Failure.network(message: e.message));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PostEntity>>> getBookmarkedPosts({
    int page = 1,
    int limit = 12,
  }) async {
    try {
      final posts = await _remoteDataSource.getBookmarkedPosts(
        page: page,
        limit: limit,
      );
      return Right(posts.map((p) => p.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(Failure.server(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(Failure.network(message: e.message));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }
}
