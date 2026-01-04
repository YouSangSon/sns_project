import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/conversation_entity.dart';
import '../models/message_model.dart';

/// 메시지 원격 데이터소스 인터페이스
abstract class MessageRemoteDataSource {
  Future<List<ConversationModel>> getConversations({int page, int limit});
  Future<ConversationModel> getConversation(String id);
  Future<ConversationModel> getOrCreateConversation(String userId);
  Future<List<MessageModel>> getMessages(String conversationId, {int page, int limit});
  Future<MessageModel> sendMessage({
    required String conversationId,
    required String content,
    MessageType type,
  });
  Future<void> markAsRead(String conversationId);
}

/// 메시지 원격 데이터소스 구현
class MessageRemoteDataSourceImpl implements MessageRemoteDataSource {
  final DioClient _client;

  MessageRemoteDataSourceImpl(this._client);

  @override
  Future<List<ConversationModel>> getConversations({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _client.get(
        ApiEndpoints.conversations,
        queryParameters: {'page': page, 'limit': limit},
      );
      final list = response.data['conversations'] as List;
      return list
          .map((json) => ConversationModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<ConversationModel> getConversation(String id) async {
    try {
      final response = await _client.get(ApiEndpoints.conversation(id));
      return ConversationModel.fromJson(response.data as Map<String, dynamic>);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<ConversationModel> getOrCreateConversation(String userId) async {
    try {
      final response = await _client.post(
        ApiEndpoints.conversations,
        data: {'user_id': userId},
      );
      return ConversationModel.fromJson(response.data as Map<String, dynamic>);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<MessageModel>> getMessages(
    String conversationId, {
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final response = await _client.get(
        ApiEndpoints.messages(conversationId),
        queryParameters: {'page': page, 'limit': limit},
      );
      final list = response.data['messages'] as List;
      return list
          .map((json) => MessageModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<MessageModel> sendMessage({
    required String conversationId,
    required String content,
    MessageType type = MessageType.text,
  }) async {
    try {
      final response = await _client.post(
        ApiEndpoints.messages(conversationId),
        data: {
          'content': content,
          'type': type.name,
        },
      );
      return MessageModel.fromJson(response.data as Map<String, dynamic>);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> markAsRead(String conversationId) async {
    try {
      await _client.post(ApiEndpoints.markAsRead(conversationId));
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
