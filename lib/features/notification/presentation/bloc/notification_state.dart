import 'package:equatable/equatable.dart';
import '../../domain/entities/notification.dart';

/// Base class for notification states
abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class NotificationInitial extends NotificationState {
  const NotificationInitial();
}

/// Loading state
class NotificationLoading extends NotificationState {
  const NotificationLoading();
}

/// Notifications loaded state
class NotificationsLoaded extends NotificationState {
  final List<NotificationEntity> notifications;
  final int unreadCount;

  const NotificationsLoaded({
    required this.notifications,
    this.unreadCount = 0,
  });

  bool get hasUnread => unreadCount > 0;

  @override
  List<Object> get props => [notifications, unreadCount];
}

/// Unread count loaded state
class UnreadCountLoaded extends NotificationState {
  final int count;

  const UnreadCountLoaded(this.count);

  @override
  List<Object> get props => [count];
}

/// Notification action success
class NotificationActionSuccess extends NotificationState {
  final String message;

  const NotificationActionSuccess(this.message);

  @override
  List<Object> get props => [message];
}

/// Failure state
class NotificationFailure extends NotificationState {
  final String message;

  const NotificationFailure(this.message);

  @override
  List<Object> get props => [message];
}
