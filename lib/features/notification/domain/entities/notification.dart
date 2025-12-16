import 'package:equatable/equatable.dart';

/// Notification type enum matching backend
enum NotificationType {
  BOOKING_REQUEST,
  BOOKING_CONFIRMED,
  BOOKING_REJECTED,
  BOOKING_CANCELLED,
  TRIP_STARTED,
  TRIP_COMPLETED,
  PAYMENT_SUCCESS,
  PAYMENT_FAILED,
  SYSTEM_ALERT;

  static NotificationType fromString(String value) {
    return NotificationType.values.firstWhere(
      (e) => e.name == value.toUpperCase(),
      orElse: () => NotificationType.SYSTEM_ALERT,
    );
  }
}

/// Notification entity - pure Dart object
class NotificationEntity extends Equatable {
  final String id;
  final String receiverId;
  final String? senderId;
  final NotificationType type;
  final String title;
  final String message;
  final String? bookingId;
  final bool isRead;
  final DateTime createdAt;
  final DateTime? readAt;

  const NotificationEntity({
    required this.id,
    required this.receiverId,
    this.senderId,
    required this.type,
    required this.title,
    required this.message,
    this.bookingId,
    required this.isRead,
    required this.createdAt,
    this.readAt,
  });

  /// Check if notification is unread
  bool get isUnread => !isRead;

  /// Check if notification is about booking
  bool get isBookingNotification => bookingId != null;

  /// Get notification icon based on type
  String get iconName {
    switch (type) {
      case NotificationType.BOOKING_REQUEST:
        return 'pending_actions';
      case NotificationType.BOOKING_CONFIRMED:
        return 'check_circle';
      case NotificationType.BOOKING_REJECTED:
        return 'cancel';
      case NotificationType.BOOKING_CANCELLED:
        return 'event_busy';
      case NotificationType.TRIP_STARTED:
        return 'play_circle';
      case NotificationType.TRIP_COMPLETED:
        return 'task_alt';
      case NotificationType.PAYMENT_SUCCESS:
        return 'payments';
      case NotificationType.PAYMENT_FAILED:
        return 'error';
      case NotificationType.SYSTEM_ALERT:
        return 'notifications';
    }
  }

  @override
  List<Object?> get props => [
    id,
    receiverId,
    senderId,
    type,
    title,
    message,
    bookingId,
    isRead,
    createdAt,
    readAt,
  ];

  NotificationEntity copyWith({
    String? id,
    String? receiverId,
    String? senderId,
    NotificationType? type,
    String? title,
    String? message,
    String? bookingId,
    bool? isRead,
    DateTime? createdAt,
    DateTime? readAt,
  }) {
    return NotificationEntity(
      id: id ?? this.id,
      receiverId: receiverId ?? this.receiverId,
      senderId: senderId ?? this.senderId,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      bookingId: bookingId ?? this.bookingId,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
    );
  }
}
