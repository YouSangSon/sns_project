import 'package:cloud_firestore/cloud_firestore.dart';

class ReelModel {
  final String reelId;
  final String userId;
  final String username;
  final String userPhotoUrl;
  final String videoUrl;
  final String thumbnailUrl;
  final String caption;
  final String? audioUrl;
  final String? audioName;
  final List<String> hashtags;
  final int likes;
  final int comments;
  final int views;
  final int shares;
  final double duration; // in seconds
  final DateTime createdAt;
  final DateTime updatedAt;

  ReelModel({
    required this.reelId,
    required this.userId,
    required this.username,
    required this.userPhotoUrl,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.caption,
    this.audioUrl,
    this.audioName,
    this.hashtags = const [],
    this.likes = 0,
    this.comments = 0,
    this.views = 0,
    this.shares = 0,
    required this.duration,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert Firestore document to ReelModel
  factory ReelModel.fromMap(Map<String, dynamic> map) {
    return ReelModel(
      reelId: map['reelId'] ?? '',
      userId: map['userId'] ?? '',
      username: map['username'] ?? '',
      userPhotoUrl: map['userPhotoUrl'] ?? '',
      videoUrl: map['videoUrl'] ?? '',
      thumbnailUrl: map['thumbnailUrl'] ?? '',
      caption: map['caption'] ?? '',
      audioUrl: map['audioUrl'],
      audioName: map['audioName'],
      hashtags: List<String>.from(map['hashtags'] ?? []),
      likes: map['likes'] ?? 0,
      comments: map['comments'] ?? 0,
      views: map['views'] ?? 0,
      shares: map['shares'] ?? 0,
      duration: (map['duration'] ?? 0.0).toDouble(),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Convert Firestore DocumentSnapshot to ReelModel
  factory ReelModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ReelModel.fromMap(data);
  }

  // Convert ReelModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'reelId': reelId,
      'userId': userId,
      'username': username,
      'userPhotoUrl': userPhotoUrl,
      'videoUrl': videoUrl,
      'thumbnailUrl': thumbnailUrl,
      'caption': caption,
      'audioUrl': audioUrl,
      'audioName': audioName,
      'hashtags': hashtags,
      'likes': likes,
      'comments': comments,
      'views': views,
      'shares': shares,
      'duration': duration,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // CopyWith method for immutability
  ReelModel copyWith({
    String? reelId,
    String? userId,
    String? username,
    String? userPhotoUrl,
    String? videoUrl,
    String? thumbnailUrl,
    String? caption,
    String? audioUrl,
    String? audioName,
    List<String>? hashtags,
    int? likes,
    int? comments,
    int? views,
    int? shares,
    double? duration,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ReelModel(
      reelId: reelId ?? this.reelId,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      userPhotoUrl: userPhotoUrl ?? this.userPhotoUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      caption: caption ?? this.caption,
      audioUrl: audioUrl ?? this.audioUrl,
      audioName: audioName ?? this.audioName,
      hashtags: hashtags ?? this.hashtags,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      views: views ?? this.views,
      shares: shares ?? this.shares,
      duration: duration ?? this.duration,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Extract hashtags from caption
  static List<String> extractHashtags(String text) {
    final hashtagPattern = RegExp(r'#([a-zA-Z0-9_]+)');
    final matches = hashtagPattern.allMatches(text);
    return matches.map((match) => match.group(1)!).toList();
  }
}
