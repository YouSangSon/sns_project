import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../auth/data/models/user_model.dart';
import '../../domain/entities/story_entity.dart';

part 'story_model.freezed.dart';
part 'story_model.g.dart';

/// 스토리 그룹 모델 (DTO)
@freezed
class StoryGroupModel with _$StoryGroupModel {
  const StoryGroupModel._();

  const factory StoryGroupModel({
    required UserModel user,
    required List<StoryModel> stories,
    @JsonKey(name: 'has_unviewed') @Default(false) bool hasUnviewed,
  }) = _StoryGroupModel;

  factory StoryGroupModel.fromJson(Map<String, dynamic> json) =>
      _$StoryGroupModelFromJson(json);

  /// Entity로 변환
  StoryGroupEntity toEntity() => StoryGroupEntity(
        user: user.toEntity(),
        stories: stories.map((s) => s.toEntity()).toList(),
        hasUnviewed: hasUnviewed,
      );
}

/// 스토리 모델 (DTO)
@freezed
class StoryModel with _$StoryModel {
  const StoryModel._();

  const factory StoryModel({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    required StoryType type,
    @JsonKey(name: 'media_url') required String mediaUrl,
    @JsonKey(name: 'thumbnail_url') String? thumbnailUrl,
    @JsonKey(name: 'is_viewed') @Default(false) bool isViewed,
    @JsonKey(name: 'view_count') @Default(0) int viewCount,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'expires_at') DateTime? expiresAt,
  }) = _StoryModel;

  factory StoryModel.fromJson(Map<String, dynamic> json) =>
      _$StoryModelFromJson(json);

  /// Entity로 변환
  StoryEntity toEntity() => StoryEntity(
        id: id,
        userId: userId,
        type: type,
        mediaUrl: mediaUrl,
        thumbnailUrl: thumbnailUrl,
        isViewed: isViewed,
        viewCount: viewCount,
        createdAt: createdAt,
        expiresAt: expiresAt,
      );
}
