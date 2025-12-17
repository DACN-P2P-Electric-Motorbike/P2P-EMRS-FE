import 'package:equatable/equatable.dart';

/// Base class for notification events
abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

/// Load notifications event
class LoadNotificationsEvent extends NotificationEvent {
  final int? limit;
  final int? offset;

  const LoadNotificationsEvent({this.limit, this.offset});

  @override
  List<Object?> get props => [limit, offset];
}

/// Mark notifications as read event
class MarkAsReadEvent extends NotificationEvent {
  final List<String> notificationIds;

  const MarkAsReadEvent(this.notificationIds);

  @override
  List<Object> get props => [notificationIds];
}

/// Mark all notifications as read event
class MarkAllAsReadEvent extends NotificationEvent {
  const MarkAllAsReadEvent();
}

/// Delete notification event
class DeleteNotificationEvent extends NotificationEvent {
  final String notificationId;

  const DeleteNotificationEvent(this.notificationId);

  @override
  List<Object> get props => [notificationId];
}

/// Get unread count event
class GetUnreadCountEvent extends NotificationEvent {
  const GetUnreadCountEvent();
}

/// Reset notification state event
class ResetNotificationStateEvent extends NotificationEvent {
  const ResetNotificationStateEvent();
}
