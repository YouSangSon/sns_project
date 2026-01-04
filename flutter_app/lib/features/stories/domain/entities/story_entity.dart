import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../auth/domain/entities/user_entity.dart';

part 'story_entity.freezed.dart';

/// 스토리 그룹 엔티티 (사용자별)
@freezed
class StoryGroupEntity with _$StoryGroupEntity {
  const factory StoryGroupEntity({
    required UserEntity user,
    required List<StoryEntity> stories,
    @Default(false) bool hasUnviewed,
  }) = _StoryGroupEntity;
}

/// 스토리 엔티티
@freezed
class StoryEntity with _$StoryEntity {
  const factory StoryEntity({
    required String id,
    required String userId,
    required StoryType type,
    required String mediaUrl,
    String? thumbnailUrl,
    @Default(false) bool isViewed,
    @Default(0) int viewCount,
    DateTime? createdAt,
    DateTime? expiresAt,
  }) = _StoryEntity;
}

/// 스토리 타입
enum StoryType {
  image,
  video,
}
