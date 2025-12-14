import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/auth_response_model.dart';
import '../models/register_params.dart';

/// Abstract class for auth remote data source
abstract class AuthRemoteDataSource {
  /// Register a new user
  Future<AuthResponseModel> register(RegisterParams params);

  /// Login user with email and password
  Future<AuthResponseModel> login(LoginParams params);

  /// Get current user profile
  Future<AuthResponseModel> getProfile();
}

/// Implementation of AuthRemoteDataSource using DioClient
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient _dioClient;

  AuthRemoteDataSourceImpl({required DioClient dioClient})
    : _dioClient = dioClient;

  @override
  Future<AuthResponseModel> register(RegisterParams params) async {
    try {
      final response = await _dioClient.post(
        ApiConstants.authRegister,
        data: params.toJson(),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return AuthResponseModel.fromJson(
          response.data as Map<String, dynamic>,
        );
      }

      throw ServerException(
        message: 'Registration failed',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<AuthResponseModel> login(LoginParams params) async {
    try {
      final response = await _dioClient.post(
        ApiConstants.authLogin,
        data: params.toJson(),
      );

      if (response.statusCode == 200) {
        return AuthResponseModel.fromJson(
          response.data as Map<String, dynamic>,
        );
      }

      throw ServerException(
        message: 'Login failed',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<AuthResponseModel> getProfile() async {
    try {
      final response = await _dioClient.get(ApiConstants.authProfile);

      if (response.statusCode == 200) {
        // The profile endpoint returns just the user, not the full auth response
        // We don't have a token here, so we create a dummy response
        return AuthResponseModel.fromJson({
          'user': response.data,
          'accessToken': '', // Token is already stored
        });
      }

      throw ServerException(
        message: 'Failed to get profile',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Handle Dio errors and convert to app exceptions
  AppException _handleDioError(DioException error) {
    final response = error.response;

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return const NetworkException();
    }

    if (error.type == DioExceptionType.connectionError) {
      return const NetworkException();
    }

    if (response != null) {
      final statusCode = response.statusCode;
      final data = response.data;

      String message = 'An error occurred';
      if (data is Map<String, dynamic> && data.containsKey('message')) {
        final msgValue = data['message'];
        if (msgValue is String) {
          message = msgValue;
        } else if (msgValue is List) {
          message = msgValue.join(', ');
        }
      }

      switch (statusCode) {
        case 401:
          return AuthenticationException(message: message);
        case 409:
          return ConflictException(message: message);
        case 400:
          return ServerException(message: message, statusCode: statusCode);
        default:
          return ServerException(message: message, statusCode: statusCode);
      }
    }

    return ServerException(
      message: error.message ?? 'An error occurred',
      statusCode: null,
    );
  }
}
