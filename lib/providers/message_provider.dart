import 'package:flutter/material.dart';
import '../models/message_model.dart';
import '../services/database_service.dart';
import '../services/storage_service.dart';

class MessageProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  final StorageService _storageService = StorageService();

  List<ConversationModel> _conversations = [];
  List<MessageModel> _messages = [];
  ConversationModel? _currentConversation;
  bool _isLoading = false;
  String? _errorMessage;

  List<ConversationModel> get conversations => _conversations;
  List<MessageModel> get messages => _messages;
  ConversationModel? get currentConversation => _currentConversation;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Load user's conversations
  Future<void> loadConversations(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      _conversations = await _databaseService.getUserConversations(userId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Load messages from a conversation
  Stream<List<MessageModel>> getMessagesStream(String conversationId) {
    return _databaseService.getMessagesStream(conversationId);
  }

  // Send text message
  Future<bool> sendMessage({
    required String conversationId,
    required String senderId,
    required String text,
  }) async {
    try {
      await _databaseService.sendMessage(
        conversationId: conversationId,
        senderId: senderId,
        text: text,
        type: 'text',
      );

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Send media message
  Future<bool> sendMediaMessage({
    required String conversationId,
    required String senderId,
    required String mediaPath,
    required String mediaType,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Upload media
      final mediaUrl = await _storageService.uploadMessageMedia(mediaPath, mediaType);

      if (mediaUrl == null) {
        throw Exception('Failed to upload media');
      }

      // Send message
      await _databaseService.sendMessage(
        conversationId: conversationId,
        senderId: senderId,
        text: '',
        type: mediaType,
        mediaUrl: mediaUrl,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Create or get conversation
  Future<String?> createOrGetConversation({
    required String currentUserId,
    required String otherUserId,
  }) async {
    try {
      final conversationId = await _databaseService.createOrGetConversation(
        currentUserId,
        otherUserId,
      );

      return conversationId;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  // Mark messages as read
  Future<void> markMessagesAsRead(String conversationId, String userId) async {
    try {
      await _databaseService.markMessagesAsRead(conversationId, userId);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
