import 'package:cloud_firestore/cloud_firestore.dart';

class StoryModel {
  final String storyId;
  final String userId;
  final String username;
  final String userPhotoUrl;
  final String mediaUrl;
  final String mediaType; // 'image' or 'video'
  final List<String> views;
  final DateTime createdAt;
  final DateTime expiresAt;

  StoryModel({
    required this.storyId,
    required this.userId,
    required this.username,
    required this.userPhotoUrl,
    required this.mediaUrl,
    required this.mediaType,
    this.views = const [],
    required this.createdAt,
    required this.expiresAt,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'storyId': storyId,
      'userId': userId,
      'username': username,
      'userPhotoUrl': userPhotoUrl,
      'mediaUrl': mediaUrl,
      'mediaType': mediaType,
      'views': views,
      'createdAt': Timestamp.fromDate(createdAt),
      'expiresAt': Timestamp.fromDate(expiresAt),
    };
  }

  // Create from Firestore document
  factory StoryModel.fromMap(Map<String, dynamic> map) {
    return StoryModel(
      storyId: map['storyId'] ?? '',
      userId: map['userId'] ?? '',
      username: map['username'] ?? '',
      userPhotoUrl: map['userPhotoUrl'] ?? '',
      mediaUrl: map['mediaUrl'] ?? '',
      mediaType: map['mediaType'] ?? 'image',
      views: List<String>.from(map['views'] ?? []),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      expiresAt: (map['expiresAt'] as Timestamp).toDate(),
    );
  }

  // Create from DocumentSnapshot
  factory StoryModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return StoryModel.fromMap(data);
  }

  // Check if story is expired
  bool get isExpired {
    return DateTime.now().isAfter(expiresAt);
  }

  // Get view count
  int get viewCount => views.length;

  // CopyWith method
  StoryModel copyWith({
    String? storyId,
    String? userId,
    String? username,
    String? userPhotoUrl,
    String? mediaUrl,
    String? mediaType,
    List<String>? views,
    DateTime? createdAt,
    DateTime? expiresAt,
  }) {
    return StoryModel(
      storyId: storyId ?? this.storyId,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      userPhotoUrl: userPhotoUrl ?? this.userPhotoUrl,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      mediaType: mediaType ?? this.mediaType,
      views: views ?? this.views,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}
