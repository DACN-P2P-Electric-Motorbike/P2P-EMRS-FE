import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/handover.dart';
import '../models/handover_model.dart';

abstract class HandoverRemoteDataSource {
  Future<VehicleHandoverModel> createCheckIn({
    required String bookingId,
    required List<HandoverPhotoInput> photos,
    double? odometerReading,
    int? batteryLevel,
    double? latitude,
    double? longitude,
    String? notes,
  });

  Future<VehicleHandoverModel> createCheckOut({
    required String bookingId,
    required List<HandoverPhotoInput> photos,
    double? odometerReading,
    int? batteryLevel,
    double? latitude,
    double? longitude,
    String? notes,
  });

  Future<HandoverSummaryModel> getByBooking(String bookingId);

  Future<VehicleHandoverModel> confirm(String handoverId);
}

class HandoverRemoteDataSourceImpl implements HandoverRemoteDataSource {
  final DioClient _dioClient;

  HandoverRemoteDataSourceImpl({required DioClient dioClient})
    : _dioClient = dioClient;

  @override
  Future<VehicleHandoverModel> createCheckIn({
    required String bookingId,
    required List<HandoverPhotoInput> photos,
    double? odometerReading,
    int? batteryLevel,
    double? latitude,
    double? longitude,
    String? notes,
  }) {
    return _create(
      endpoint: ApiConstants.handoverCheckIn,
      bookingId: bookingId,
      photos: photos,
      odometerReading: odometerReading,
      batteryLevel: batteryLevel,
      latitude: latitude,
      longitude: longitude,
      notes: notes,
    );
  }

  @override
  Future<VehicleHandoverModel> createCheckOut({
    required String bookingId,
    required List<HandoverPhotoInput> photos,
    double? odometerReading,
    int? batteryLevel,
    double? latitude,
    double? longitude,
    String? notes,
  }) {
    return _create(
      endpoint: ApiConstants.handoverCheckOut,
      bookingId: bookingId,
      photos: photos,
      odometerReading: odometerReading,
      batteryLevel: batteryLevel,
      latitude: latitude,
      longitude: longitude,
      notes: notes,
    );
  }

  @override
  Future<HandoverSummaryModel> getByBooking(String bookingId) async {
    try {
      final response = await _dioClient.get(
        ApiConstants.handoverByBooking(bookingId),
      );
      if (response.statusCode == 200) {
        return HandoverSummaryModel.fromJson(
          response.data as Map<String, dynamic>,
        );
      }
      throw ServerException(
        message: 'Failed to load handover summary',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw const ServerException(
          message: 'Máy chủ hiện chưa hỗ trợ bàn giao xe. Vui lòng thử lại sau.',
          statusCode: 404,
        );
      }
      throw ServerException.fromDioException(e);
    }
  }

  @override
  Future<VehicleHandoverModel> confirm(String handoverId) async {
    try {
      final response = await _dioClient.patch(
        ApiConstants.confirmHandover(handoverId),
      );
      if (response.statusCode == 200) {
        return VehicleHandoverModel.fromJson(
          response.data as Map<String, dynamic>,
        );
      }
      throw ServerException(
        message: 'Failed to confirm handover',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw ServerException.fromDioException(e);
    }
  }

  Future<VehicleHandoverModel> _create({
    required String endpoint,
    required String bookingId,
    required List<HandoverPhotoInput> photos,
    double? odometerReading,
    int? batteryLevel,
    double? latitude,
    double? longitude,
    String? notes,
  }) async {
    try {
      final response = await _dioClient.post(
        endpoint,
        data: {
          'bookingId': bookingId,
          'photos': photos.map((photo) => photo.toJson()).toList(),
          if (odometerReading != null) 'odometerReading': odometerReading,
          if (batteryLevel != null) 'batteryLevel': batteryLevel,
          if (latitude != null) 'latitude': latitude,
          if (longitude != null) 'longitude': longitude,
          if (notes?.trim().isNotEmpty == true) 'notes': notes!.trim(),
        },
      );
      if (response.statusCode == 201) {
        return VehicleHandoverModel.fromJson(
          response.data as Map<String, dynamic>,
        );
      }
      throw ServerException(
        message: 'Failed to submit handover',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw ServerException.fromDioException(e);
    }
  }
}
