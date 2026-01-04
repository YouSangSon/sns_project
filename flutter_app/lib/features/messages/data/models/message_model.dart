import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../auth/data/models/user_model.dart';
import '../../domain/entities/conversation_entity.dart';

part 'message_model.freezed.dart';
part 'message_model.g.dart';

/// 대화방 모델 (DTO)
@freezed
class ConversationModel with _$ConversationModel {
  const ConversationModel._();

  const factory ConversationModel({
    required String id,
    required List<UserModel> participants,
    @JsonKey(name: 'last_message') MessageModel? lastMessage,
    @JsonKey(name: 'unread_count') @Default(0) int unreadCount,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _ConversationModel;

  factory ConversationModel.fromJson(Map<String, dynamic> json) =>
      _$ConversationModelFromJson(json);

  /// Entity로 변환
  ConversationEntity toEntity() => ConversationEntity(
        id: id,
        participants: participants.map((p) => p.toEntity()).toList(),
        lastMessage: lastMessage?.toEntity(),
        unreadCount: unreadCount,
        updatedAt: updatedAt,
      );
}

/// 메시지 모델 (DTO)
@freezed
class MessageModel with _$MessageModel {
  const MessageModel._();

  const factory MessageModel({
    required String id,
    @JsonKey(name: 'conversation_id') required String conversationId,
    required UserModel sender,
    required String content,
    MessageType? type,
    @JsonKey(name: 'is_read') @Default(false) bool isRead,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _MessageModel;

  factory MessageModel.fromJson(Map<String, dynamic> json) =>
      _$MessageModelFromJson(json);

  /// Entity로 변환
  MessageEntity toEntity() => MessageEntity(
        id: id,
        conversationId: conversationId,
        sender: sender.toEntity(),
        content: content,
        type: type,
        isRead: isRead,
        createdAt: createdAt,
      );
}
