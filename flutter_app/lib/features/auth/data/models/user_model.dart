import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/user_entity.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

/// 사용자 모델 (DTO)
@freezed
class UserModel with _$UserModel {
  const UserModel._();

  const factory UserModel({
    required String id,
    required String email,
    required String username,
    required String name,
    String? bio,
    @JsonKey(name: 'profile_image_url') String? profileImageUrl,
    @JsonKey(name: 'followers_count') @Default(0) int followersCount,
    @JsonKey(name: 'following_count') @Default(0) int followingCount,
    @JsonKey(name: 'posts_count') @Default(0) int postsCount,
    @JsonKey(name: 'is_following') @Default(false) bool isFollowing,
    @JsonKey(name: 'is_verified') @Default(false) bool isVerified,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  /// Entity로 변환
  UserEntity toEntity() => UserEntity(
        id: id,
        email: email,
        username: username,
        name: name,
        bio: bio,
        profileImageUrl: profileImageUrl,
        followersCount: followersCount,
        followingCount: followingCount,
        postsCount: postsCount,
        isFollowing: isFollowing,
        isVerified: isVerified,
        createdAt: createdAt,
      );

  /// Entity에서 변환
  factory UserModel.fromEntity(UserEntity entity) => UserModel(
        id: entity.id,
        email: entity.email,
        username: entity.username,
        name: entity.name,
        bio: entity.bio,
        profileImageUrl: entity.profileImageUrl,
        followersCount: entity.followersCount,
        followingCount: entity.followingCount,
        postsCount: entity.postsCount,
        isFollowing: entity.isFollowing,
        isVerified: entity.isVerified,
        createdAt: entity.createdAt,
      );
}

/// 인증 응답 모델
@freezed
class AuthResponseModel with _$AuthResponseModel {
  const factory AuthResponseModel({
    required UserModel user,
    @JsonKey(name: 'access_token') required String accessToken,
    @JsonKey(name: 'refresh_token') required String refreshToken,
  }) = _AuthResponseModel;

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseModelFromJson(json);
}
