import 'package:equatable/equatable.dart';

class Comment extends Equatable {
  final String commentId;
  final String postId;
  final String userId;
  final String username;
  final String? userPhotoUrl;
  final String text;
  final int likes;
  final bool isLiked;
  final DateTime createdAt;

  const Comment({
    required this.commentId,
    required this.postId,
    required this.userId,
    required this.username,
    this.userPhotoUrl,
    required this.text,
    this.likes = 0,
    this.isLiked = false,
    required this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      commentId: json['commentId'] ?? '',
      postId: json['postId'] ?? '',
      userId: json['userId'] ?? '',
      username: json['username'] ?? '',
      userPhotoUrl: json['userPhotoUrl'],
      text: json['text'] ?? '',
      likes: json['likes'] ?? 0,
      isLiked: json['isLiked'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'commentId': commentId,
      'postId': postId,
      'userId': userId,
      'username': username,
      'userPhotoUrl': userPhotoUrl,
      'text': text,
      'likes': likes,
      'isLiked': isLiked,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        commentId,
        postId,
        userId,
        username,
        userPhotoUrl,
        text,
        likes,
        isLiked,
        createdAt,
      ];
}

class CreateCommentDto {
  final String postId;
  final String text;

  const CreateCommentDto({
    required this.postId,
    required this.text,
  });

  Map<String, dynamic> toJson() {
    return {
      'postId': postId,
      'text': text,
    };
  }
}
