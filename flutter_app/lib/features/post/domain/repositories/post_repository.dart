import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../feed/domain/entities/post_entity.dart';

/// 게시물 레포지토리 인터페이스
abstract class PostRepository {
  /// 게시물 상세 조회
  Future<Either<Failure, PostEntity>> getPost(String id);

  /// 게시물 생성
  Future<Either<Failure, PostEntity>> createPost({
    String? content,
    List<String>? imagePaths,
    String? location,
  });

  /// 게시물 수정
  Future<Either<Failure, PostEntity>> updatePost({
    required String id,
    String? content,
    String? location,
  });

  /// 게시물 삭제
  Future<Either<Failure, void>> deletePost(String id);

  /// 게시물 좋아요
  Future<Either<Failure, PostEntity>> likePost(String id);

  /// 게시물 좋아요 취소
  Future<Either<Failure, PostEntity>> unlikePost(String id);

  /// 게시물 북마크
  Future<Either<Failure, void>> bookmarkPost(String id);

  /// 게시물 북마크 취소
  Future<Either<Failure, void>> unbookmarkPost(String id);

  /// 댓글 목록 조회
  Future<Either<Failure, List<CommentEntity>>> getComments(
    String postId, {
    int page = 1,
    int limit = 20,
  });

  /// 댓글 작성
  Future<Either<Failure, CommentEntity>> createComment({
    required String postId,
    required String content,
  });

  /// 댓글 삭제
  Future<Either<Failure, void>> deleteComment(String id);
}
