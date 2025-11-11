import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String notificationId;
  final String userId; // 알림 받는 사람
  final String fromUserId; // 알림 보낸 사람
  final String fromUsername;
  final String fromUserPhotoUrl;
  final String type; // 'like', 'comment', 'follow', 'mention'
  final String? postId;
  final String? postImageUrl;
  final String text;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.notificationId,
    required this.userId,
    required this.fromUserId,
    required this.fromUsername,
    required this.fromUserPhotoUrl,
    required this.type,
    this.postId,
    this.postImageUrl,
    required this.text,
    this.isRead = false,
    required this.createdAt,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'notificationId': notificationId,
      'userId': userId,
      'fromUserId': fromUserId,
      'fromUsername': fromUsername,
      'fromUserPhotoUrl': fromUserPhotoUrl,
      'type': type,
      'postId': postId,
      'postImageUrl': postImageUrl,
      'text': text,
      'isRead': isRead,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Create from Firestore document
  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      notificationId: map['notificationId'] ?? '',
      userId: map['userId'] ?? '',
      fromUserId: map['fromUserId'] ?? '',
      fromUsername: map['fromUsername'] ?? '',
      fromUserPhotoUrl: map['fromUserPhotoUrl'] ?? '',
      type: map['type'] ?? '',
      postId: map['postId'],
      postImageUrl: map['postImageUrl'],
      text: map['text'] ?? '',
      isRead: map['isRead'] ?? false,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  // Create from DocumentSnapshot
  factory NotificationModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationModel.fromMap(data);
  }

  // CopyWith method
  NotificationModel copyWith({
    String? notificationId,
    String? userId,
    String? fromUserId,
    String? fromUsername,
    String? fromUserPhotoUrl,
    String? type,
    String? postId,
    String? postImageUrl,
    String? text,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      notificationId: notificationId ?? this.notificationId,
      userId: userId ?? this.userId,
      fromUserId: fromUserId ?? this.fromUserId,
      fromUsername: fromUsername ?? this.fromUsername,
      fromUserPhotoUrl: fromUserPhotoUrl ?? this.fromUserPhotoUrl,
      type: type ?? this.type,
      postId: postId ?? this.postId,
      postImageUrl: postImageUrl ?? this.postImageUrl,
      text: text ?? this.text,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
