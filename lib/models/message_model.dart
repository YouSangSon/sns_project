import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String messageId;
  final String conversationId;
  final String senderId;
  final String text;
  final String? mediaUrl;
  final String type; // 'text', 'image', 'video'
  final bool isRead;
  final DateTime createdAt;

  MessageModel({
    required this.messageId,
    required this.conversationId,
    required this.senderId,
    required this.text,
    this.mediaUrl,
    this.type = 'text',
    this.isRead = false,
    required this.createdAt,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'messageId': messageId,
      'conversationId': conversationId,
      'senderId': senderId,
      'text': text,
      'mediaUrl': mediaUrl,
      'type': type,
      'isRead': isRead,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Create from Firestore document
  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      messageId: map['messageId'] ?? '',
      conversationId: map['conversationId'] ?? '',
      senderId: map['senderId'] ?? '',
      text: map['text'] ?? '',
      mediaUrl: map['mediaUrl'],
      type: map['type'] ?? 'text',
      isRead: map['isRead'] ?? false,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  // Create from DocumentSnapshot
  factory MessageModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MessageModel.fromMap(data);
  }

  // CopyWith method
  MessageModel copyWith({
    String? messageId,
    String? conversationId,
    String? senderId,
    String? text,
    String? mediaUrl,
    String? type,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return MessageModel(
      messageId: messageId ?? this.messageId,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      text: text ?? this.text,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class ConversationModel {
  final String conversationId;
  final List<String> participants;
  final String lastMessage;
  final DateTime lastMessageTime;
  final Map<String, int> unreadCount;

  ConversationModel({
    required this.conversationId,
    required this.participants,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = const {},
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'conversationId': conversationId,
      'participants': participants,
      'lastMessage': lastMessage,
      'lastMessageTime': Timestamp.fromDate(lastMessageTime),
      'unreadCount': unreadCount,
    };
  }

  // Create from Firestore document
  factory ConversationModel.fromMap(Map<String, dynamic> map) {
    return ConversationModel(
      conversationId: map['conversationId'] ?? '',
      participants: List<String>.from(map['participants'] ?? []),
      lastMessage: map['lastMessage'] ?? '',
      lastMessageTime: (map['lastMessageTime'] as Timestamp).toDate(),
      unreadCount: Map<String, int>.from(map['unreadCount'] ?? {}),
    );
  }

  // Create from DocumentSnapshot
  factory ConversationModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ConversationModel.fromMap(data);
  }
}
