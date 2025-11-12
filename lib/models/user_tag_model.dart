import 'package:cloud_firestore/cloud_firestore.dart';

class UserTag {
  final String tagId;
  final String postId;
  final String userId; // Tagged user
  final String username;
  final String taggedBy; // User who created the tag
  final DateTime createdAt;

  UserTag({
    required this.tagId,
    required this.postId,
    required this.userId,
    required this.username,
    required this.taggedBy,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'tagId': tagId,
      'postId': postId,
      'userId': userId,
      'username': username,
      'taggedBy': taggedBy,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory UserTag.fromMap(Map<String, dynamic> map) {
    return UserTag(
      tagId: map['tagId'] ?? '',
      postId: map['postId'] ?? '',
      userId: map['userId'] ?? '',
      username: map['username'] ?? '',
      taggedBy: map['taggedBy'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  factory UserTag.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserTag.fromMap({
      ...data,
      'tagId': doc.id,
    });
  }

  UserTag copyWith({
    String? tagId,
    String? postId,
    String? userId,
    String? username,
    String? taggedBy,
    DateTime? createdAt,
  }) {
    return UserTag(
      tagId: tagId ?? this.tagId,
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      taggedBy: taggedBy ?? this.taggedBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
