import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/notification.dart';

/// Abstract repository interface for notifications
abstract class NotificationRepository {
  /// Get user notifications
  Future<Either<Failure, List<NotificationEntity>>> getNotifications({
    int limit = 50,
    int offset = 0,
  });

  /// Get unread count
  Future<Either<Failure, int>> getUnreadCount();

  /// Mark notifications as read
  Future<Either<Failure, void>> markAsRead(List<String> notificationIds);

  /// Mark all notifications as read
  Future<Either<Failure, void>> markAllAsRead();

  /// Delete notification
  Future<Either<Failure, void>> deleteNotification(String notificationId);

  /// Register FCM token
  Future<Either<Failure, void>> registerFcmToken(String token, String platform);

  /// Unregister FCM token
  Future<Either<Failure, void>> unregisterFcmToken(String token);
}
