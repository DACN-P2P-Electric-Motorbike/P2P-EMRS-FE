import 'package:dio/dio.dart';
import '../../../../../core/constants/api_constants.dart';
import '../../../../../core/error/exceptions.dart';
import '../../../../../core/network/dio_client.dart';
import '../models/vehicle_model.dart';

/// Remote data source for vehicle operations
abstract class VehicleRemoteDataSource {
  Future<List<VehicleModel>> getAvailableVehicles({
    DateTime? startTime,
    DateTime? endTime,
  });
  Future<VehicleModel> getVehicleById(String id);
  Future<List<VehicleModel>> searchVehicles({
    String? brand,
    String? model,
    double? maxPrice,
    double? latitude,
    double? longitude,
    double? radius,
  });
  Future<List<VehicleModel>> getNearbyVehicles({
    required double latitude,
    required double longitude,
    double radius = 5.0,
    DateTime? startTime,
    DateTime? endTime,
  });
}

class VehicleRemoteDataSourceImpl implements VehicleRemoteDataSource {
  final DioClient _dioClient;

  VehicleRemoteDataSourceImpl({required DioClient dioClient})
    : _dioClient = dioClient;

  @override
  Future<List<VehicleModel>> getAvailableVehicles({
    DateTime? startTime,
    DateTime? endTime,
  }) async {
    try {
      final queryParameters = <String, dynamic>{};
      if (startTime != null) {
        queryParameters['startTime'] = startTime.toIso8601String();
      }
      if (endTime != null) {
        queryParameters['endTime'] = endTime.toIso8601String();
      }

      final response = await _dioClient.get(
        ApiConstants.availableVehicles,
        queryParameters: queryParameters.isEmpty ? null : queryParameters,
      );

      final data = response.data;

      if (data is Map<String, dynamic> && data['vehicles'] is List) {
        return (data['vehicles'] as List)
            .map((json) => VehicleModel.fromJson(json))
            .toList();
      }

      throw const ServerException(message: 'Invalid response format');
    } on DioException catch (e) {
      throw ServerException.fromDioException(e);
    }
  }

  @override
  Future<VehicleModel> getVehicleById(String id) async {
    try {
      final response = await _dioClient.get(ApiConstants.vehicleById(id));

      return VehicleModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ServerException.fromDioException(e);
    }
  }

  @override
  Future<List<VehicleModel>> searchVehicles({
    String? brand,
    String? model,
    double? maxPrice,
    double? latitude,
    double? longitude,
    double? radius,
  }) async {
    try {
      final queryParameters = <String, dynamic>{};

      if (brand != null) queryParameters['brand'] = brand;
      if (model != null) queryParameters['model'] = model;
      if (maxPrice != null) queryParameters['maxPrice'] = maxPrice;
      if (latitude != null) queryParameters['latitude'] = latitude;
      if (longitude != null) queryParameters['longitude'] = longitude;
      if (radius != null) queryParameters['radius'] = radius;

      final response = await _dioClient.get(
        '${ApiConstants.vehicles}/search',
        queryParameters: queryParameters,
      );

      if (response.data is List) {
        return (response.data as List)
            .map((json) => VehicleModel.fromJson(json))
            .toList();
      }

      throw const ServerException(message: 'Invalid response format');
    } on DioException catch (e) {
      throw ServerException.fromDioException(e);
    }
  }

  @override
  Future<List<VehicleModel>> getNearbyVehicles({
    required double latitude,
    required double longitude,
    double radius = 5.0,
    DateTime? startTime,
    DateTime? endTime,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        'latitude': latitude,
        'longitude': longitude,
        'radiusKm': radius,
      };
      if (startTime != null) {
        queryParameters['startTime'] = startTime.toIso8601String();
      }
      if (endTime != null) {
        queryParameters['endTime'] = endTime.toIso8601String();
      }

      final response = await _dioClient.get(
        ApiConstants.availableVehicles,
        queryParameters: queryParameters,
      );

      final data = response.data;
      if (data is Map<String, dynamic> && data['vehicles'] is List) {
        return (data['vehicles'] as List)
            .map((json) => VehicleModel.fromJson(json))
            .toList();
      }

      throw const ServerException(message: 'Invalid response format');
    } on DioException catch (e) {
      throw ServerException.fromDioException(e);
    }
  }
}
