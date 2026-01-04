import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../feed/domain/entities/post_entity.dart';
import '../../domain/repositories/search_repository.dart';
import '../datasources/search_remote_datasource.dart';

/// 검색 레포지토리 구현
class SearchRepositoryImpl implements SearchRepository {
  final SearchRemoteDataSource _remoteDataSource;
  static const String _recentSearchesKey = 'recent_searches';

  SearchRepositoryImpl({required SearchRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, List<UserEntity>>> searchUsers(
    String query, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final users = await _remoteDataSource.searchUsers(
        query,
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
  Future<Either<Failure, List<PostEntity>>> searchPosts(
    String query, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final posts = await _remoteDataSource.searchPosts(
        query,
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
  Future<Either<Failure, List<PostEntity>>> getExploreFeed({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final posts = await _remoteDataSource.getExploreFeed(
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
  Future<Either<Failure, List<String>>> getRecentSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final searches = prefs.getStringList(_recentSearchesKey) ?? [];
      return Right(searches);
    } catch (e) {
      return Left(Failure.cache(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveSearch(String query) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final searches = prefs.getStringList(_recentSearchesKey) ?? [];

      // 중복 제거 후 맨 앞에 추가
      searches.remove(query);
      searches.insert(0, query);

      // 최대 10개 유지
      if (searches.length > 10) {
        searches.removeLast();
      }

      await prefs.setStringList(_recentSearchesKey, searches);
      return const Right(null);
    } catch (e) {
      return Left(Failure.cache(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> clearRecentSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_recentSearchesKey);
      return const Right(null);
    } catch (e) {
      return Left(Failure.cache(message: e.toString()));
    }
  }
}
