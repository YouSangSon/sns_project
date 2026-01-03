import 'package:equatable/equatable.dart';

class Post extends Equatable {
  final String postId;
  final String userId;
  final String username;
  final String? userPhotoUrl;
  final List<String> imageUrls;
  final String? caption;
  final String? location;
  final int likes;
  final int comments;
  final bool isLiked;
  final bool isBookmarked;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Post({
    required this.postId,
    required this.userId,
    required this.username,
    this.userPhotoUrl,
    required this.imageUrls,
    this.caption,
    this.location,
    this.likes = 0,
    this.comments = 0,
    this.isLiked = false,
    this.isBookmarked = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      postId: json['postId'] ?? '',
      userId: json['userId'] ?? '',
      username: json['username'] ?? '',
      userPhotoUrl: json['userPhotoUrl'],
      imageUrls: (json['imageUrls'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      caption: json['caption'],
      location: json['location'],
      likes: json['likes'] ?? 0,
      comments: json['comments'] ?? 0,
      isLiked: json['isLiked'] ?? false,
      isBookmarked: json['isBookmarked'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'postId': postId,
      'userId': userId,
      'username': username,
      'userPhotoUrl': userPhotoUrl,
      'imageUrls': imageUrls,
      'caption': caption,
      'location': location,
      'likes': likes,
      'comments': comments,
      'isLiked': isLiked,
      'isBookmarked': isBookmarked,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Post copyWith({
    String? postId,
    String? userId,
    String? username,
    String? userPhotoUrl,
    List<String>? imageUrls,
    String? caption,
    String? location,
    int? likes,
    int? comments,
    bool? isLiked,
    bool? isBookmarked,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Post(
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      userPhotoUrl: userPhotoUrl ?? this.userPhotoUrl,
      imageUrls: imageUrls ?? this.imageUrls,
      caption: caption ?? this.caption,
      location: location ?? this.location,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      isLiked: isLiked ?? this.isLiked,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        postId,
        userId,
        username,
        userPhotoUrl,
        imageUrls,
        caption,
        location,
        likes,
        comments,
        isLiked,
        isBookmarked,
        createdAt,
        updatedAt,
      ];
}

class CreatePostDto {
  final String? caption;
  final List<String> imageUrls;
  final String? location;

  const CreatePostDto({
    this.caption,
    required this.imageUrls,
    this.location,
  });

  Map<String, dynamic> toJson() {
    return {
      'caption': caption,
      'imageUrls': imageUrls,
      'location': location,
    };
  }
}
