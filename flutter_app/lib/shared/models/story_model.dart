import 'package:equatable/equatable.dart';

class Story extends Equatable {
  final String storyId;
  final String userId;
  final String username;
  final String? userPhotoUrl;
  final String mediaUrl;
  final String mediaType; // 'image' or 'video'
  final int views;
  final bool isViewed;
  final DateTime createdAt;
  final DateTime expiresAt;

  const Story({
    required this.storyId,
    required this.userId,
    required this.username,
    this.userPhotoUrl,
    required this.mediaUrl,
    this.mediaType = 'image',
    this.views = 0,
    this.isViewed = false,
    required this.createdAt,
    required this.expiresAt,
  });

  factory Story.fromJson(Map<String, dynamic> json) {
    return Story(
      storyId: json['storyId'] ?? '',
      userId: json['userId'] ?? '',
      username: json['username'] ?? '',
      userPhotoUrl: json['userPhotoUrl'],
      mediaUrl: json['mediaUrl'] ?? '',
      mediaType: json['mediaType'] ?? 'image',
      views: json['views'] ?? 0,
      isViewed: json['isViewed'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'])
          : DateTime.now().add(const Duration(hours: 24)),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'storyId': storyId,
      'userId': userId,
      'username': username,
      'userPhotoUrl': userPhotoUrl,
      'mediaUrl': mediaUrl,
      'mediaType': mediaType,
      'views': views,
      'isViewed': isViewed,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
    };
  }

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  @override
  List<Object?> get props => [
        storyId,
        userId,
        username,
        userPhotoUrl,
        mediaUrl,
        mediaType,
        views,
        isViewed,
        createdAt,
        expiresAt,
      ];
}

class UserStories extends Equatable {
  final String userId;
  final String username;
  final String? userPhotoUrl;
  final List<Story> stories;
  final bool hasUnviewed;

  const UserStories({
    required this.userId,
    required this.username,
    this.userPhotoUrl,
    required this.stories,
    this.hasUnviewed = false,
  });

  factory UserStories.fromJson(Map<String, dynamic> json) {
    return UserStories(
      userId: json['userId'] ?? '',
      username: json['username'] ?? '',
      userPhotoUrl: json['userPhotoUrl'],
      stories: (json['stories'] as List<dynamic>?)
              ?.map((e) => Story.fromJson(e))
              .toList() ??
          [],
      hasUnviewed: json['hasUnviewed'] ?? false,
    );
  }

  @override
  List<Object?> get props => [
        userId,
        username,
        userPhotoUrl,
        stories,
        hasUnviewed,
      ];
}
