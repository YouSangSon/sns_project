import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/conversation_entity.dart';

/// 메시지 레포지토리 인터페이스
abstract class MessageRepository {
  /// 대화방 목록 조회
  Future<Either<Failure, List<ConversationEntity>>> getConversations({
    int page = 1,
    int limit = 20,
  });

  /// 대화방 상세 조회
  Future<Either<Failure, ConversationEntity>> getConversation(String id);

  /// 대화방 생성 또는 조회
  Future<Either<Failure, ConversationEntity>> getOrCreateConversation(
      String userId);

  /// 메시지 목록 조회
  Future<Either<Failure, List<MessageEntity>>> getMessages(
    String conversationId, {
    int page = 1,
    int limit = 50,
  });

  /// 메시지 전송
  Future<Either<Failure, MessageEntity>> sendMessage({
    required String conversationId,
    required String content,
    MessageType type = MessageType.text,
  });

  /// 메시지 읽음 처리
  Future<Either<Failure, void>> markAsRead(String conversationId);

  /// 실시간 메시지 스트림
  Stream<MessageEntity> get messageStream;
}
