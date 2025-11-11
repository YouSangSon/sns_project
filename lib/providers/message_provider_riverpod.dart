import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/message_model.dart';
import '../services/database_service.dart';
import '../services/storage_service.dart';

// Conversations provider
final conversationsProvider = FutureProvider.family<List<ConversationModel>, String>((ref, userId) async {
  final databaseService = DatabaseService();
  return await databaseService.getUserConversations(userId);
});

// Messages stream provider
final messagesStreamProvider = StreamProvider.family<List<MessageModel>, String>((ref, conversationId) {
  final databaseService = DatabaseService();
  return databaseService.getMessagesStream(conversationId);
});

// Message notifier for mutations
class MessageNotifier extends StateNotifier<AsyncValue<void>> {
  final DatabaseService _databaseService = DatabaseService();
  final StorageService _storageService = StorageService();

  MessageNotifier() : super(const AsyncValue.data(null));

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
      return false;
    }
  }

  Future<bool> sendMediaMessage({
    required String conversationId,
    required String senderId,
    required String mediaPath,
    required String mediaType,
  }) async {
    try {
      state = const AsyncValue.loading();

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

      state = const AsyncValue.data(null);
      return true;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return false;
    }
  }

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
      return null;
    }
  }

  Future<void> markMessagesAsRead(String conversationId, String userId) async {
    try {
      await _databaseService.markMessagesAsRead(conversationId, userId);
    } catch (e) {
      // Handle error silently
    }
  }
}

final messageNotifierProvider = StateNotifierProvider<MessageNotifier, AsyncValue<void>>((ref) {
  return MessageNotifier();
});
