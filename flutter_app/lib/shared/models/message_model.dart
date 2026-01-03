import 'package:equatable/equatable.dart';

class Message extends Equatable {
  final String messageId;
  final String conversationId;
  final String senderId;
  final String receiverId;
  final String? text;
  final String? imageUrl;
  final bool isRead;
  final DateTime createdAt;

  const Message({
    required this.messageId,
    required this.conversationId,
    required this.senderId,
    required this.receiverId,
    this.text,
    this.imageUrl,
    this.isRead = false,
    required this.createdAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      messageId: json['messageId'] ?? '',
      conversationId: json['conversationId'] ?? '',
      senderId: json['senderId'] ?? '',
      receiverId: json['receiverId'] ?? '',
      text: json['text'],
      imageUrl: json['imageUrl'],
      isRead: json['isRead'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'messageId': messageId,
      'conversationId': conversationId,
      'senderId': senderId,
      'receiverId': receiverId,
      'text': text,
      'imageUrl': imageUrl,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        messageId,
        conversationId,
        senderId,
        receiverId,
        text,
        imageUrl,
        isRead,
        createdAt,
      ];
}

class Conversation extends Equatable {
  final String conversationId;
  final String participantId;
  final String participantUsername;
  final String? participantPhotoUrl;
  final Message? lastMessage;
  final int unreadCount;
  final DateTime updatedAt;

  const Conversation({
    required this.conversationId,
    required this.participantId,
    required this.participantUsername,
    this.participantPhotoUrl,
    this.lastMessage,
    this.unreadCount = 0,
    required this.updatedAt,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      conversationId: json['conversationId'] ?? '',
      participantId: json['participantId'] ?? '',
      participantUsername: json['participantUsername'] ?? '',
      participantPhotoUrl: json['participantPhotoUrl'],
      lastMessage: json['lastMessage'] != null
          ? Message.fromJson(json['lastMessage'])
          : null,
      unreadCount: json['unreadCount'] ?? 0,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        conversationId,
        participantId,
        participantUsername,
        participantPhotoUrl,
        lastMessage,
        unreadCount,
        updatedAt,
      ];
}

class SendMessageDto {
  final String receiverId;
  final String text;
  final String? imageUrl;

  const SendMessageDto({
    required this.receiverId,
    required this.text,
    this.imageUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'receiverId': receiverId,
      'text': text,
      'imageUrl': imageUrl,
    };
  }
}
