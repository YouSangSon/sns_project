import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/conversation_entity.dart';
import '../repositories/message_repository.dart';

/// 대화방 목록 조회 유즈케이스
class GetConversationsUseCase {
  final MessageRepository _repository;

  GetConversationsUseCase(this._repository);

  Future<Either<Failure, List<ConversationEntity>>> call({
    int page = 1,
    int limit = 20,
  }) {
    return _repository.getConversations(page: page, limit: limit);
  }
}
