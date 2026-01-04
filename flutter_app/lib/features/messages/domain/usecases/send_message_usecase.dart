import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/conversation_entity.dart';
import '../repositories/message_repository.dart';

/// 메시지 전송 유즈케이스
class SendMessageUseCase {
  final MessageRepository _repository;

  SendMessageUseCase(this._repository);

  Future<Either<Failure, MessageEntity>> call({
    required String conversationId,
    required String content,
    MessageType type = MessageType.text,
  }) {
    return _repository.sendMessage(
      conversationId: conversationId,
      content: content,
      type: type,
    );
  }
}
