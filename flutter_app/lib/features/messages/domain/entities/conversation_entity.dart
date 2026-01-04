import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../auth/domain/entities/user_entity.dart';

part 'conversation_entity.freezed.dart';

/// 대화방 엔티티
@freezed
class ConversationEntity with _$ConversationEntity {
  const factory ConversationEntity({
    required String id,
    required List<UserEntity> participants,
    MessageEntity? lastMessage,
    @Default(0) int unreadCount,
    DateTime? updatedAt,
  }) = _ConversationEntity;
}

/// 메시지 엔티티
@freezed
class MessageEntity with _$MessageEntity {
  const factory MessageEntity({
    required String id,
    required String conversationId,
    required UserEntity sender,
    required String content,
    MessageType? type,
    @Default(false) bool isRead,
    DateTime? createdAt,
  }) = _MessageEntity;
}

/// 메시지 타입
enum MessageType {
  text,
  image,
  video,
}
