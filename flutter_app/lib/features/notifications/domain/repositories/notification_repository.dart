import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/notification_entity.dart';

/// 알림 레포지토리 인터페이스
abstract class NotificationRepository {
  /// 알림 목록 조회
  Future<Either<Failure, List<NotificationEntity>>> getNotifications({
    int page = 1,
    int limit = 20,
  });

  /// 알림 읽음 처리
  Future<Either<Failure, void>> markAsRead(String id);

  /// 모든 알림 읽음 처리
  Future<Either<Failure, void>> markAllAsRead();

  /// 읽지 않은 알림 수 조회
  Future<Either<Failure, int>> getUnreadCount();

  /// 실시간 알림 스트림
  Stream<NotificationEntity> get notificationStream;
}
