import 'package:dio/dio.dart';

/// Base exception class
class AppException implements Exception {
  final String message;
  final int? statusCode;

  const AppException({required this.message, this.statusCode});

  @override
  String toString() => 'AppException: $message (statusCode: $statusCode)';
}

/// Server exception - thrown when API returns an error
class ServerException extends AppException {
  const ServerException({required super.message, super.statusCode});

  /// Create ServerException from DioException
  factory ServerException.fromDioException(DioException e) {
    String message = 'An unexpected error occurred.';
    int? statusCode = e.response?.statusCode;

    final responseData = e.response?.data;
    if (responseData is Map<String, dynamic> || responseData is Map) {
      final data = Map<String, dynamic>.from(responseData as Map);
      if (data.containsKey('message')) {
        final msg = data['message'];
        if (msg is String) {
          message = msg;
        } else if (msg is List) {
          // Join array messages into a single readable string
          message = msg.map((m) => m.toString()).join(', ');
        }
      }
    } else if (responseData is String && responseData.trim().isNotEmpty) {
      message = responseData;
    } else {
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          message = 'Connection timeout. Please try again.';
          break;
        case DioExceptionType.connectionError:
          message = 'No internet connection';
          break;
        case DioExceptionType.badResponse:
          message = e.response?.statusMessage ?? 'Server error';
          break;
        default:
          message = e.message ?? 'Unknown error';
      }
    }

    return ServerException(message: message, statusCode: statusCode);
  }
}

/// Network exception - thrown when there's no connection
class NetworkException extends AppException {
  const NetworkException()
    : super(message: 'No internet connection', statusCode: null);
}

/// Connection exception - alias for NetworkException (for backwards compatibility)
typedef ConnectionException = NetworkException;

/// Authentication exception - thrown for auth-related errors
class AuthenticationException extends AppException {
  const AuthenticationException({super.message = 'Authentication failed'})
    : super(statusCode: 401);
}

/// Conflict exception - thrown when resource already exists
class ConflictException extends AppException {
  const ConflictException({super.message = 'Resource already exists'})
    : super(statusCode: 409);
}

/// Cache exception - thrown when local storage fails
class CacheException extends AppException {
  const CacheException()
    : super(message: 'Failed to access local storage', statusCode: null);
}
