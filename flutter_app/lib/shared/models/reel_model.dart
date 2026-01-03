import 'package:equatable/equatable.dart';

class Reel extends Equatable {
  final String reelId;
  final String userId;
  final String username;
  final String? userPhotoUrl;
  final String videoUrl;
  final String? thumbnailUrl;
  final String? caption;
  final String? audioName;
  final int likes;
  final int comments;
  final int shares;
  final int views;
  final bool isLiked;
  final bool isBookmarked;
  final DateTime createdAt;

  const Reel({
    required this.reelId,
    required this.userId,
    required this.username,
    this.userPhotoUrl,
    required this.videoUrl,
    this.thumbnailUrl,
    this.caption,
    this.audioName,
    this.likes = 0,
    this.comments = 0,
    this.shares = 0,
    this.views = 0,
    this.isLiked = false,
    this.isBookmarked = false,
    required this.createdAt,
  });

  factory Reel.fromJson(Map<String, dynamic> json) {
    return Reel(
      reelId: json['reelId'] ?? '',
      userId: json['userId'] ?? '',
      username: json['username'] ?? '',
      userPhotoUrl: json['userPhotoUrl'],
      videoUrl: json['videoUrl'] ?? '',
      thumbnailUrl: json['thumbnailUrl'],
      caption: json['caption'],
      audioName: json['audioName'],
      likes: json['likes'] ?? 0,
      comments: json['comments'] ?? 0,
      shares: json['shares'] ?? 0,
      views: json['views'] ?? 0,
      isLiked: json['isLiked'] ?? false,
      isBookmarked: json['isBookmarked'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reelId': reelId,
      'userId': userId,
      'username': username,
      'userPhotoUrl': userPhotoUrl,
      'videoUrl': videoUrl,
      'thumbnailUrl': thumbnailUrl,
      'caption': caption,
      'audioName': audioName,
      'likes': likes,
      'comments': comments,
      'shares': shares,
      'views': views,
      'isLiked': isLiked,
      'isBookmarked': isBookmarked,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Reel copyWith({
    String? reelId,
    String? userId,
    String? username,
    String? userPhotoUrl,
    String? videoUrl,
    String? thumbnailUrl,
    String? caption,
    String? audioName,
    int? likes,
    int? comments,
    int? shares,
    int? views,
    bool? isLiked,
    bool? isBookmarked,
    DateTime? createdAt,
  }) {
    return Reel(
      reelId: reelId ?? this.reelId,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      userPhotoUrl: userPhotoUrl ?? this.userPhotoUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      caption: caption ?? this.caption,
      audioName: audioName ?? this.audioName,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      shares: shares ?? this.shares,
      views: views ?? this.views,
      isLiked: isLiked ?? this.isLiked,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        reelId,
        userId,
        username,
        userPhotoUrl,
        videoUrl,
        thumbnailUrl,
        caption,
        audioName,
        likes,
        comments,
        shares,
        views,
        isLiked,
        isBookmarked,
        createdAt,
      ];
}
