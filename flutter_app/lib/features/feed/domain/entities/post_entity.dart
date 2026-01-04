import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../auth/domain/entities/user_entity.dart';

part 'post_entity.freezed.dart';

/// 게시물 엔티티
@freezed
class PostEntity with _$PostEntity {
  const factory PostEntity({
    required String id,
    required UserEntity author,
    String? content,
    @Default([]) List<String> imageUrls,
    @Default(0) int likesCount,
    @Default(0) int commentsCount,
    @Default(false) bool isLiked,
    @Default(false) bool isBookmarked,
    String? location,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _PostEntity;
}

/// 댓글 엔티티
@freezed
class CommentEntity with _$CommentEntity {
  const factory CommentEntity({
    required String id,
    required String postId,
    required UserEntity author,
    required String content,
    @Default(0) int likesCount,
    @Default(false) bool isLiked,
    DateTime? createdAt,
  }) = _CommentEntity;
}
