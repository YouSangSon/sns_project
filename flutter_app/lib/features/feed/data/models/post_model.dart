import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../auth/data/models/user_model.dart';
import '../../domain/entities/post_entity.dart';

part 'post_model.freezed.dart';
part 'post_model.g.dart';

/// 게시물 모델 (DTO)
@freezed
class PostModel with _$PostModel {
  const PostModel._();

  const factory PostModel({
    required String id,
    required UserModel author,
    String? content,
    @JsonKey(name: 'image_urls') @Default([]) List<String> imageUrls,
    @JsonKey(name: 'likes_count') @Default(0) int likesCount,
    @JsonKey(name: 'comments_count') @Default(0) int commentsCount,
    @JsonKey(name: 'is_liked') @Default(false) bool isLiked,
    @JsonKey(name: 'is_bookmarked') @Default(false) bool isBookmarked,
    String? location,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _PostModel;

  factory PostModel.fromJson(Map<String, dynamic> json) =>
      _$PostModelFromJson(json);

  /// Entity로 변환
  PostEntity toEntity() => PostEntity(
        id: id,
        author: author.toEntity(),
        content: content,
        imageUrls: imageUrls,
        likesCount: likesCount,
        commentsCount: commentsCount,
        isLiked: isLiked,
        isBookmarked: isBookmarked,
        location: location,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}

/// 댓글 모델 (DTO)
@freezed
class CommentModel with _$CommentModel {
  const CommentModel._();

  const factory CommentModel({
    required String id,
    @JsonKey(name: 'post_id') required String postId,
    required UserModel author,
    required String content,
    @JsonKey(name: 'likes_count') @Default(0) int likesCount,
    @JsonKey(name: 'is_liked') @Default(false) bool isLiked,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _CommentModel;

  factory CommentModel.fromJson(Map<String, dynamic> json) =>
      _$CommentModelFromJson(json);

  /// Entity로 변환
  CommentEntity toEntity() => CommentEntity(
        id: id,
        postId: postId,
        author: author.toEntity(),
        content: content,
        likesCount: likesCount,
        isLiked: isLiked,
        createdAt: createdAt,
      );
}

/// 피드 응답 모델
@freezed
class FeedResponseModel with _$FeedResponseModel {
  const factory FeedResponseModel({
    required List<PostModel> posts,
    @JsonKey(name: 'has_more') @Default(false) bool hasMore,
    @JsonKey(name: 'next_page') int? nextPage,
  }) = _FeedResponseModel;

  factory FeedResponseModel.fromJson(Map<String, dynamic> json) =>
      _$FeedResponseModelFromJson(json);
}
