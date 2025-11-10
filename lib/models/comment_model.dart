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

  CommentModel({
    required this.commentId,
    required this.postId,
    required this.userId,
    required this.username,
    required this.userPhotoUrl,
    required this.text,
    this.likes = 0,
    required this.createdAt,
  });

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
    );
  }
}
