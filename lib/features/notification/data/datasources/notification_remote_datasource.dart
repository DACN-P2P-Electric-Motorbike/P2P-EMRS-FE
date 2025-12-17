import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/notification_model.dart';

/// Abstract class for notification remote data source
abstract class NotificationRemoteDataSource {
  /// Get user notifications
  Future<List<NotificationModel>> getNotifications({
    int limit = 50,
    int offset = 0,
  });

  /// Get unread notification count
  Future<int> getUnreadCount();

  /// Mark notifications as read
  Future<void> markAsRead(List<String> notificationIds);

  /// Mark all notifications as read
  Future<void> markAllAsRead();

  /// Delete notification
  Future<void> deleteNotification(String notificationId);

  /// Register FCM token
  Future<void> registerFcmToken(String token, String platform);

  /// Unregister FCM token
  Future<void> unregisterFcmToken(String token);
}

/// Implementation using DioClient
class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final DioClient _dioClient;

  NotificationRemoteDataSourceImpl({required DioClient dioClient})
    : _dioClient = dioClient;

  @override
  Future<List<NotificationModel>> getNotifications({
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await _dioClient.get(
        '/notifications',
        queryParameters: {'limit': limit, 'offset': offset},
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;

        final List<dynamic> notifications =
            data['notifications'] as List<dynamic>? ?? [];

        return notifications
            .map(
              (json) =>
                  NotificationModel.fromJson(json as Map<String, dynamic>),
            )
            .toList();
      }

      throw ServerException(
        message: 'Failed to get notifications',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw ServerException.fromDioException(e);
    }
  }

  @override
  Future<int> getUnreadCount() async {
    try {
      final response = await _dioClient.get('/notifications/unread-count');

      if (response.statusCode == 200) {
        // Assuming response.data is {"count": 5}
        if (response.data is Map<String, dynamic>) {
          return (response.data['count'] as num?)?.toInt() ?? 0;
        }
        // Or if response.data is just a number
        if (response.data is num) {
          return response.data.toInt();
        }
        return 0;
      }

      throw ServerException(
        message: 'Failed to get unread count',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw ServerException.fromDioException(e);
    }
  }

  @override
  Future<void> markAsRead(List<String> notificationIds) async {
    try {
      final response = await _dioClient.patch(
        '/notifications/read',
        data: {'notificationIds': notificationIds},
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ServerException(
          message: 'Failed to mark notifications as read',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ServerException.fromDioException(e);
    }
  }

  @override
  Future<void> markAllAsRead() async {
    try {
      final response = await _dioClient.patch('/notifications/read-all');

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ServerException(
          message: 'Failed to mark all notifications as read',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ServerException.fromDioException(e);
    }
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    try {
      final response = await _dioClient.delete(
        '/notifications/$notificationId',
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ServerException(
          message: 'Failed to delete notification',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ServerException.fromDioException(e);
    }
  }

  @override
  Future<void> registerFcmToken(String token, String platform) async {
    try {
      final response = await _dioClient.post(
        '/fcm-token',
        data: {
          'token': token,
          'platform': platform, // 'ios' or 'android'
        },
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw ServerException(
          message: 'Failed to register FCM token',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ServerException.fromDioException(e);
    }
  }

  @override
  Future<void> unregisterFcmToken(String token) async {
    try {
      final response = await _dioClient.delete(
        '/fcm-token/$token',
        // data: {'token': token},
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ServerException(
          message: 'Failed to unregister FCM token',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ServerException.fromDioException(e);
    }
  }
}
