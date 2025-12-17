import '../../domain/entities/notification.dart';

/// Notification model for API responses
class NotificationModel {
  final String id;
  final String receiverId;
  final String? senderId;
  final String type;
  final String title;
  final String message;
  final String? bookingId;
  final bool isRead;
  final DateTime createdAt;
  final DateTime? readAt;

  const NotificationModel({
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

  /// Parse from JSON response
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      receiverId: json['receiverId'] as String,
      senderId: json['senderId'] as String?,
      type: json['type'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      bookingId: json['bookingId'] as String?,
      isRead: json['isRead'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      readAt: json['readAt'] != null
          ? DateTime.parse(json['readAt'] as String)
          : null,
    );
  }

  /// Convert to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'receiverId': receiverId,
      'senderId': senderId,
      'type': type,
      'title': title,
      'message': message,
      'bookingId': bookingId,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
      'readAt': readAt?.toIso8601String(),
    };
  }

  /// Convert to domain entity
  NotificationEntity toEntity() {
    return NotificationEntity(
      id: id,
      receiverId: receiverId,
      senderId: senderId,
      type: NotificationType.fromString(type),
      title: title,
      message: message,
      bookingId: bookingId,
      isRead: isRead,
      createdAt: createdAt,
      readAt: readAt,
    );
  }
}
