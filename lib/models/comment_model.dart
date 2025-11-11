import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String commentId;
  final String postId;
  final String userId;
  final String username;
  final String userPhotoUrl;
  final String text;
  final int likes;
  final DateTime createdAt;
  final String? parentCommentId; // For replies
  final int repliesCount;

  CommentModel({
    required this.commentId,
    required this.postId,
    required this.userId,
    required this.username,
    required this.userPhotoUrl,
    required this.text,
    this.likes = 0,
    required this.createdAt,
    this.parentCommentId,
    this.repliesCount = 0,
  });

  // Check if this is a reply
  bool get isReply => parentCommentId != null;

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'commentId': commentId,
      'postId': postId,
      'userId': userId,
      'username': username,
      'userPhotoUrl': userPhotoUrl,
      'text': text,
      'likes': likes,
      'createdAt': Timestamp.fromDate(createdAt),
      'parentCommentId': parentCommentId,
      'repliesCount': repliesCount,
    };
  }

  // Create from Firestore document
  factory CommentModel.fromMap(Map<String, dynamic> map) {
    return CommentModel(
      commentId: map['commentId'] ?? '',
      postId: map['postId'] ?? '',
      userId: map['userId'] ?? '',
      username: map['username'] ?? '',
      userPhotoUrl: map['userPhotoUrl'] ?? '',
      text: map['text'] ?? '',
      likes: map['likes'] ?? 0,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      parentCommentId: map['parentCommentId'],
      repliesCount: map['repliesCount'] ?? 0,
    );
  }

  // Create from DocumentSnapshot
  factory CommentModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CommentModel.fromMap(data);
  }

  // CopyWith method
  CommentModel copyWith({
    String? commentId,
    String? postId,
    String? userId,
    String? username,
    String? userPhotoUrl,
    String? text,
    int? likes,
    DateTime? createdAt,
    String? parentCommentId,
    int? repliesCount,
  }) {
    return CommentModel(
      commentId: commentId ?? this.commentId,
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      userPhotoUrl: userPhotoUrl ?? this.userPhotoUrl,
      text: text ?? this.text,
      likes: likes ?? this.likes,
      createdAt: createdAt ?? this.createdAt,
      parentCommentId: parentCommentId ?? this.parentCommentId,
      repliesCount: repliesCount ?? this.repliesCount,
    );
  }
}
