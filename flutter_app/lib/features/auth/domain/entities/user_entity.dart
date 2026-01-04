import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_entity.freezed.dart';

/// 사용자 엔티티
@freezed
class UserEntity with _$UserEntity {
  const factory UserEntity({
    required String id,
    required String email,
    required String username,
    required String name,
    String? bio,
    String? profileImageUrl,
    @Default(0) int followersCount,
    @Default(0) int followingCount,
    @Default(0) int postsCount,
    @Default(false) bool isFollowing,
    @Default(false) bool isVerified,
    DateTime? createdAt,
  }) = _UserEntity;
}
