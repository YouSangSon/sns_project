import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/notification_entity.dart';
import '../repositories/notification_repository.dart';

/// 알림 목록 조회 유즈케이스
class GetNotificationsUseCase {
  final NotificationRepository _repository;

  GetNotificationsUseCase(this._repository);

  Future<Either<Failure, List<NotificationEntity>>> call({
    int page = 1,
    int limit = 20,
  }) {
    return _repository.getNotifications(page: page, limit: limit);
  }
}
