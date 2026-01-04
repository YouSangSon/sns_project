import 'dart:async';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/conversation_entity.dart';
import '../../domain/repositories/message_repository.dart';
import '../datasources/message_remote_datasource.dart';

/// 메시지 레포지토리 구현
class MessageRepositoryImpl implements MessageRepository {
  final MessageRemoteDataSource _remoteDataSource;
  final StreamController<MessageEntity> _messageController =
      StreamController<MessageEntity>.broadcast();

  MessageRepositoryImpl({required MessageRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, List<ConversationEntity>>> getConversations({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final conversations = await _remoteDataSource.getConversations(
        page: page,
        limit: limit,
      );
      return Right(conversations.map((c) => c.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(Failure.server(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(Failure.network(message: e.message));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ConversationEntity>> getConversation(String id) async {
    try {
      final conversation = await _remoteDataSource.getConversation(id);
      return Right(conversation.toEntity());
    } on ServerException catch (e) {
      return Left(Failure.server(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(Failure.network(message: e.message));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ConversationEntity>> getOrCreateConversation(
      String userId) async {
    try {
      final conversation =
          await _remoteDataSource.getOrCreateConversation(userId);
      return Right(conversation.toEntity());
    } on ServerException catch (e) {
      return Left(Failure.server(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(Failure.network(message: e.message));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MessageEntity>>> getMessages(
    String conversationId, {
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final messages = await _remoteDataSource.getMessages(
        conversationId,
        page: page,
        limit: limit,
      );
      return Right(messages.map((m) => m.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(Failure.server(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(Failure.network(message: e.message));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, MessageEntity>> sendMessage({
    required String conversationId,
    required String content,
    MessageType type = MessageType.text,
  }) async {
    try {
      final message = await _remoteDataSource.sendMessage(
        conversationId: conversationId,
        content: content,
        type: type,
      );
      final entity = message.toEntity();
      _messageController.add(entity);
      return Right(entity);
    } on ServerException catch (e) {
      return Left(Failure.server(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(Failure.network(message: e.message));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markAsRead(String conversationId) async {
    try {
      await _remoteDataSource.markAsRead(conversationId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(Failure.server(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(Failure.network(message: e.message));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  @override
  Stream<MessageEntity> get messageStream => _messageController.stream;
}
