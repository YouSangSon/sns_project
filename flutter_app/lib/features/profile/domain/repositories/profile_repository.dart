import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../feed/domain/entities/post_entity.dart';

/// 프로필 레포지토리 인터페이스
abstract class ProfileRepository {
  /// 사용자 프로필 조회
  Future<Either<Failure, UserEntity>> getProfile(String userId);

  /// 내 프로필 수정
  Future<Either<Failure, UserEntity>> updateProfile({
    String? name,
    String? bio,
    String? profileImagePath,
  });

  /// 사용자 게시물 목록 조회
  Future<Either<Failure, List<PostEntity>>> getUserPosts(
    String userId, {
    int page = 1,
    int limit = 12,
  });

  /// 팔로우
  Future<Either<Failure, UserEntity>> follow(String userId);

  /// 언팔로우
  Future<Either<Failure, UserEntity>> unfollow(String userId);

  /// 팔로워 목록 조회
  Future<Either<Failure, List<UserEntity>>> getFollowers(
    String userId, {
    int page = 1,
    int limit = 20,
  });

  /// 팔로잉 목록 조회
  Future<Either<Failure, List<UserEntity>>> getFollowing(
    String userId, {
    int page = 1,
    int limit = 20,
  });

  /// 북마크 게시물 목록 조회
  Future<Either<Failure, List<PostEntity>>> getBookmarkedPosts({
    int page = 1,
    int limit = 12,
  });
}
