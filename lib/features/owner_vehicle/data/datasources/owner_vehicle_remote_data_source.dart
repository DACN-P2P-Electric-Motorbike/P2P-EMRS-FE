import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/vehicle_model.dart';
import '../models/create_vehicle_params.dart';
import '../models/update_vehicle_params.dart';

/// Abstract interface for owner vehicle remote data source
abstract class OwnerVehicleRemoteDataSource {
  /// Get all vehicles owned by the current user
  Future<List<VehicleModel>> getMyVehicles();

  /// Register a new vehicle
  Future<VehicleModel> registerVehicle(CreateVehicleParams params);

  /// Get vehicle by ID
  Future<VehicleModel> getVehicleById(String id);

  /// Update vehicle information
  Future<VehicleModel> updateVehicle(String id, UpdateVehicleParams params);

  /// Delete a vehicle
  Future<void> deleteVehicle(String id);
}

/// Implementation of OwnerVehicleRemoteDataSource
class OwnerVehicleRemoteDataSourceImpl implements OwnerVehicleRemoteDataSource {
  final DioClient _dioClient;

  OwnerVehicleRemoteDataSourceImpl({required DioClient dioClient})
      : _dioClient = dioClient;

  @override
  Future<List<VehicleModel>> getMyVehicles() async {
    try {
      final response = await _dioClient.get(ApiConstants.myVehicles);

      if (response.data is List) {
        return (response.data as List)
            .map((json) => VehicleModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      return [];
    } on DioException catch (e) {
      throw ServerException.fromDioException(e);
    }
  }

  @override
  Future<VehicleModel> registerVehicle(CreateVehicleParams params) async {
    try {
      final response = await _dioClient.post(
        ApiConstants.vehicles,
        data: params.toJson(),
      );

      return VehicleModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerException.fromDioException(e);
    }
  }

  @override
  Future<VehicleModel> getVehicleById(String id) async {
    try {
      final response = await _dioClient.get(ApiConstants.vehicleById(id));

      return VehicleModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerException.fromDioException(e);
    }
  }

  @override
  Future<VehicleModel> updateVehicle(
      String id, UpdateVehicleParams params) async {
    try {
      final response = await _dioClient.patch(
        ApiConstants.vehicleById(id),
        data: params.toJson(),
      );

      return VehicleModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerException.fromDioException(e);
    }
  }

  @override
  Future<void> deleteVehicle(String id) async {
    try {
      await _dioClient.delete(ApiConstants.vehicleById(id));
    } on DioException catch (e) {
      throw ServerException.fromDioException(e);
    }
  }
}

