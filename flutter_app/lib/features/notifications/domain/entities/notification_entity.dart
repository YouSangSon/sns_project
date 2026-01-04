import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../auth/domain/entities/user_entity.dart';

part 'notification_entity.freezed.dart';

/// 알림 엔티티
@freezed
class NotificationEntity with _$NotificationEntity {
  const factory NotificationEntity({
    required String id,
    required NotificationType type,
    required UserEntity fromUser,
    String? postId,
    String? commentId,
    String? message,
    @Default(false) bool isRead,
    DateTime? createdAt,
  }) = _NotificationEntity;
}

/// 알림 타입
enum NotificationType {
  like,
  comment,
  follow,
  mention,
  message,
}
