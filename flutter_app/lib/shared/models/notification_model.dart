import 'package:equatable/equatable.dart';

enum NotificationType { like, comment, follow, mention, other }

class AppNotification extends Equatable {
  final String notificationId;
  final String userId;
  final NotificationType type;
  final String message;
  final String? actorId;
  final String? actorUsername;
  final String? actorPhotoUrl;
  final String? relatedPostId;
  final bool isRead;
  final DateTime createdAt;

  const AppNotification({
    required this.notificationId,
    required this.userId,
    required this.type,
    required this.message,
    this.actorId,
    this.actorUsername,
    this.actorPhotoUrl,
    this.relatedPostId,
    this.isRead = false,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      notificationId: json['notificationId'] ?? '',
      userId: json['userId'] ?? '',
      type: _parseNotificationType(json['type']),
      message: json['message'] ?? '',
      actorId: json['actorId'],
      actorUsername: json['actorUsername'],
      actorPhotoUrl: json['actorPhotoUrl'],
      relatedPostId: json['relatedPostId'],
      isRead: json['isRead'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  static NotificationType _parseNotificationType(String? type) {
    switch (type) {
      case 'like':
        return NotificationType.like;
      case 'comment':
        return NotificationType.comment;
      case 'follow':
        return NotificationType.follow;
      case 'mention':
        return NotificationType.mention;
      default:
        return NotificationType.other;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'notificationId': notificationId,
      'userId': userId,
      'type': type.name,
      'message': message,
      'actorId': actorId,
      'actorUsername': actorUsername,
      'actorPhotoUrl': actorPhotoUrl,
      'relatedPostId': relatedPostId,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  AppNotification copyWith({
    String? notificationId,
    String? userId,
    NotificationType? type,
    String? message,
    String? actorId,
    String? actorUsername,
    String? actorPhotoUrl,
    String? relatedPostId,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return AppNotification(
      notificationId: notificationId ?? this.notificationId,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      message: message ?? this.message,
      actorId: actorId ?? this.actorId,
      actorUsername: actorUsername ?? this.actorUsername,
      actorPhotoUrl: actorPhotoUrl ?? this.actorPhotoUrl,
      relatedPostId: relatedPostId ?? this.relatedPostId,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        notificationId,
        userId,
        type,
        message,
        actorId,
        actorUsername,
        actorPhotoUrl,
        relatedPostId,
        isRead,
        createdAt,
      ];
}
