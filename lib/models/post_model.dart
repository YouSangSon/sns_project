import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String postId;
  final String userId;
  final String username;
  final String userPhotoUrl;
  final List<String> imageUrls;
  final String caption;
  final String location;
  final List<String> hashtags;
  final List<String> taggedUserIds; // Tagged users
  final int likes;
  final int comments;
  final DateTime createdAt;
  final DateTime updatedAt;

  PostModel({
    required this.postId,
    required this.userId,
    required this.username,
    required this.userPhotoUrl,
    required this.imageUrls,
    this.caption = '',
    this.location = '',
    this.hashtags = const [],
    this.taggedUserIds = const [],
    this.likes = 0,
    this.comments = 0,
    required this.createdAt,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? createdAt;

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'postId': postId,
      'userId': userId,
      'username': username,
      'userPhotoUrl': userPhotoUrl,
      'imageUrls': imageUrls,
      'caption': caption,
      'location': location,
      'hashtags': hashtags,
      'taggedUserIds': taggedUserIds,
      'likes': likes,
      'comments': comments,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Create from Firestore document
  factory PostModel.fromMap(Map<String, dynamic> map) {
    return PostModel(
      postId: map['postId'] ?? '',
      userId: map['userId'] ?? '',
      username: map['username'] ?? '',
      userPhotoUrl: map['userPhotoUrl'] ?? '',
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      caption: map['caption'] ?? '',
      location: map['location'] ?? '',
      hashtags: List<String>.from(map['hashtags'] ?? []),
      taggedUserIds: List<String>.from(map['taggedUserIds'] ?? []),
      likes: map['likes'] ?? 0,
      comments: map['comments'] ?? 0,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  // Create from DocumentSnapshot
  factory PostModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PostModel.fromMap(data);
  }

  // Extract hashtags from caption
  static List<String> extractHashtags(String text) {
    final RegExp hashtagRegex = RegExp(r'#\w+');
    final matches = hashtagRegex.allMatches(text);
    return matches.map((match) => match.group(0)!.toLowerCase()).toList();
  }

  // CopyWith method
  PostModel copyWith({
    String? postId,
    String? userId,
    String? username,
    String? userPhotoUrl,
    List<String>? imageUrls,
    String? caption,
    String? location,
    List<String>? hashtags,
    List<String>? taggedUserIds,
    int? likes,
    int? comments,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PostModel(
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      userPhotoUrl: userPhotoUrl ?? this.userPhotoUrl,
      imageUrls: imageUrls ?? this.imageUrls,
      caption: caption ?? this.caption,
      location: location ?? this.location,
      hashtags: hashtags ?? this.hashtags,
      taggedUserIds: taggedUserIds ?? this.taggedUserIds,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
