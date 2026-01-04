import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../auth/data/models/user_model.dart';
import '../../domain/entities/notification_entity.dart';

part 'notification_model.freezed.dart';
part 'notification_model.g.dart';

/// 알림 모델 (DTO)
@freezed
class NotificationModel with _$NotificationModel {
  const NotificationModel._();

  const factory NotificationModel({
    required String id,
    required NotificationType type,
    @JsonKey(name: 'from_user') required UserModel fromUser,
    @JsonKey(name: 'post_id') String? postId,
    @JsonKey(name: 'comment_id') String? commentId,
    String? message,
    @JsonKey(name: 'is_read') @Default(false) bool isRead,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _NotificationModel;

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationModelFromJson(json);

  /// Entity로 변환
  NotificationEntity toEntity() => NotificationEntity(
        id: id,
        type: type,
        fromUser: fromUser.toEntity(),
        postId: postId,
        commentId: commentId,
        message: message,
        isRead: isRead,
        createdAt: createdAt,
      );
}
