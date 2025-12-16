import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/notification.dart';
import '../repositories/notification_repository.dart';

/// Get notifications use case
class GetNotificationsParams extends Equatable {
  final int limit;
  final int offset;

  const GetNotificationsParams({this.limit = 50, this.offset = 0});

  @override
  List<Object> get props => [limit, offset];
}

class GetNotificationsUseCase
    implements UseCase<List<NotificationEntity>, GetNotificationsParams> {
  final NotificationRepository _repository;

  GetNotificationsUseCase(this._repository);

  @override
  Future<Either<Failure, List<NotificationEntity>>> call(
    GetNotificationsParams params,
  ) async {
    return await _repository.getNotifications(
      limit: params.limit,
      offset: params.offset,
    );
  }
}

/// Get unread count use case
class GetUnreadCountUseCase implements UseCase<int, NoParams> {
  final NotificationRepository _repository;

  GetUnreadCountUseCase(this._repository);

  @override
  Future<Either<Failure, int>> call(NoParams params) async {
    return await _repository.getUnreadCount();
  }
}

/// Mark notifications as read use case
class MarkAsReadParams extends Equatable {
  final List<String> notificationIds;

  const MarkAsReadParams(this.notificationIds);

  @override
  List<Object> get props => [notificationIds];
}

class MarkAsReadUseCase implements UseCase<void, MarkAsReadParams> {
  final NotificationRepository _repository;

  MarkAsReadUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(MarkAsReadParams params) async {
    return await _repository.markAsRead(params.notificationIds);
  }
}

/// Mark all notifications as read use case
class MarkAllAsReadUseCase implements UseCase<void, NoParams> {
  final NotificationRepository _repository;

  MarkAllAsReadUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await _repository.markAllAsRead();
  }
}

/// Delete notification use case
class DeleteNotificationParams extends Equatable {
  final String notificationId;

  const DeleteNotificationParams(this.notificationId);

  @override
  List<Object> get props => [notificationId];
}

class DeleteNotificationUseCase
    implements UseCase<void, DeleteNotificationParams> {
  final NotificationRepository _repository;

  DeleteNotificationUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(DeleteNotificationParams params) async {
    return await _repository.deleteNotification(params.notificationId);
  }
}

/// Register FCM token use case
class RegisterFcmTokenParams extends Equatable {
  final String token;
  final String platform;

  const RegisterFcmTokenParams({required this.token, required this.platform});

  @override
  List<Object> get props => [token, platform];
}

class RegisterFcmTokenUseCase implements UseCase<void, RegisterFcmTokenParams> {
  final NotificationRepository _repository;

  RegisterFcmTokenUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(RegisterFcmTokenParams params) async {
    return await _repository.registerFcmToken(params.token, params.platform);
  }
}

/// Unregister FCM token use case
class UnregisterFcmTokenParams extends Equatable {
  final String token;

  const UnregisterFcmTokenParams(this.token);

  @override
  List<Object> get props => [token];
}

class UnregisterFcmTokenUseCase
    implements UseCase<void, UnregisterFcmTokenParams> {
  final NotificationRepository _repository;

  UnregisterFcmTokenUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(UnregisterFcmTokenParams params) async {
    return await _repository.unregisterFcmToken(params.token);
  }
}
