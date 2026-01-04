import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../feed/domain/entities/post_entity.dart';

/// 검색 레포지토리 인터페이스
abstract class SearchRepository {
  /// 사용자 검색
  Future<Either<Failure, List<UserEntity>>> searchUsers(
    String query, {
    int page = 1,
    int limit = 20,
  });

  /// 게시물 검색 (해시태그)
  Future<Either<Failure, List<PostEntity>>> searchPosts(
    String query, {
    int page = 1,
    int limit = 20,
  });

  /// 탐색 피드 조회 (추천 게시물)
  Future<Either<Failure, List<PostEntity>>> getExploreFeed({
    int page = 1,
    int limit = 20,
  });

  /// 최근 검색어 조회
  Future<Either<Failure, List<String>>> getRecentSearches();

  /// 검색어 저장
  Future<Either<Failure, void>> saveSearch(String query);

  /// 최근 검색어 삭제
  Future<Either<Failure, void>> clearRecentSearches();
}
