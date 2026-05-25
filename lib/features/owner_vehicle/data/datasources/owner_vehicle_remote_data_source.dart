import 'dart:async';

import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/cache/hive_cache_service.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/vehicle_model.dart';
import '../models/availability_window_model.dart';
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

  /// Toggle vehicle availability (on/off for rent)
  Future<VehicleModel> toggleAvailability(String id);

  /// Get owner-managed availability windows for a vehicle
  Future<List<VehicleAvailabilityWindowModel>> getAvailabilityWindows(
    String vehicleId,
  );

  /// Create an owner-managed availability window
  Future<VehicleAvailabilityWindowModel> createAvailabilityWindow(
    String vehicleId,
    CreateAvailabilityWindowParams params,
  );

  /// Update an owner-managed availability window
  Future<VehicleAvailabilityWindowModel> updateAvailabilityWindow(
    String vehicleId,
    String windowId,
    CreateAvailabilityWindowParams params,
  );

  /// Delete an owner-managed availability window
  Future<void> deleteAvailabilityWindow(String vehicleId, String windowId);

  /// Delete a vehicle
  Future<void> deleteVehicle(String id);
}

/// Implementation of OwnerVehicleRemoteDataSource
class OwnerVehicleRemoteDataSourceImpl implements OwnerVehicleRemoteDataSource {
  final DioClient _dioClient;
  final HiveCacheService _cache;

  OwnerVehicleRemoteDataSourceImpl({
    required DioClient dioClient,
    required HiveCacheService cache,
  }) : _dioClient = dioClient,
       _cache = cache;

  @override
  Future<List<VehicleModel>> getMyVehicles() async {
    const cacheKey = 'owner.vehicles';
    final cached = await _cachedVehicleList(cacheKey);
    if (cached != null) {
      unawaited(_refreshMyVehicles(cacheKey));
      return cached;
    }

    return _fetchAndCacheMyVehicles(cacheKey);
  }

  @override
  Future<VehicleModel> registerVehicle(CreateVehicleParams params) async {
    try {
      final response = await _dioClient.post(
        ApiConstants.vehicles,
        data: params.toJson(),
      );

      final vehicle = VehicleModel.fromJson(
        response.data as Map<String, dynamic>,
      );
      await _cache.write('owner.vehicle:${vehicle.id}', vehicle.toJson());
      await _cache.delete('owner.vehicles');
      return vehicle;
    } on DioException catch (e) {
      throw ServerException.fromDioException(e);
    }
  }

  @override
  Future<VehicleModel> getVehicleById(String id) async {
    final cacheKey = 'owner.vehicle:$id';
    final cached = await _cache.read<Map<dynamic, dynamic>>(cacheKey);
    if (cached != null) {
      unawaited(_refreshVehicleDetail(cacheKey, id));
      return VehicleModel.fromJson(Map<String, dynamic>.from(cached));
    }

    try {
      final response = await _dioClient.get(ApiConstants.vehicleById(id));
      final vehicle = VehicleModel.fromJson(
        response.data as Map<String, dynamic>,
      );
      await _cache.write(cacheKey, vehicle.toJson());
      return vehicle;
    } on DioException catch (e) {
      throw ServerException.fromDioException(e);
    }
  }

  @override
  Future<VehicleModel> updateVehicle(
    String id,
    UpdateVehicleParams params,
  ) async {
    try {
      final response = await _dioClient.patch(
        ApiConstants.vehicleById(id),
        data: params.toJson(),
      );

      final vehicle = VehicleModel.fromJson(
        response.data as Map<String, dynamic>,
      );
      await _cache.write('owner.vehicle:$id', vehicle.toJson());
      await _cache.delete('owner.vehicles');
      return vehicle;
    } on DioException catch (e) {
      throw ServerException.fromDioException(e);
    }
  }

  @override
  Future<VehicleModel> toggleAvailability(String id) async {
    try {
      final response = await _dioClient.patch(
        ApiConstants.toggleVehicleAvailability(id),
      );

      final vehicle = VehicleModel.fromJson(
        response.data as Map<String, dynamic>,
      );
      await _cache.write('owner.vehicle:$id', vehicle.toJson());
      await _cache.delete('owner.vehicles');
      return vehicle;
    } on DioException catch (e) {
      throw ServerException.fromDioException(e);
    }
  }

  @override
  Future<List<VehicleAvailabilityWindowModel>> getAvailabilityWindows(
    String vehicleId,
  ) async {
    try {
      final response = await _dioClient.get(
        ApiConstants.vehicleAvailability(vehicleId),
      );
      if (response.data is! List) return [];

      return (response.data as List)
          .whereType<Map>()
          .map(
            (json) => VehicleAvailabilityWindowModel.fromJson(
              Map<String, dynamic>.from(json),
            ),
          )
          .toList();
    } on DioException catch (e) {
      throw ServerException.fromDioException(e);
    }
  }

  @override
  Future<VehicleAvailabilityWindowModel> createAvailabilityWindow(
    String vehicleId,
    CreateAvailabilityWindowParams params,
  ) async {
    try {
      final response = await _dioClient.post(
        ApiConstants.vehicleAvailability(vehicleId),
        data: params.toJson(),
      );
      return VehicleAvailabilityWindowModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw ServerException.fromDioException(e);
    }
  }

  @override
  Future<VehicleAvailabilityWindowModel> updateAvailabilityWindow(
    String vehicleId,
    String windowId,
    CreateAvailabilityWindowParams params,
  ) async {
    try {
      final response = await _dioClient.patch(
        ApiConstants.vehicleAvailabilityWindow(vehicleId, windowId),
        data: params.toJson(),
      );
      return VehicleAvailabilityWindowModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw ServerException.fromDioException(e);
    }
  }

  @override
  Future<void> deleteAvailabilityWindow(
    String vehicleId,
    String windowId,
  ) async {
    try {
      await _dioClient.delete(
        ApiConstants.vehicleAvailabilityWindow(vehicleId, windowId),
      );
    } on DioException catch (e) {
      throw ServerException.fromDioException(e);
    }
  }

  @override
  Future<void> deleteVehicle(String id) async {
    try {
      await _dioClient.delete(ApiConstants.vehicleById(id));
      await _cache.delete('owner.vehicle:$id');
      await _cache.delete('owner.vehicles');
    } on DioException catch (e) {
      throw ServerException.fromDioException(e);
    }
  }

  Future<List<VehicleModel>?> _cachedVehicleList(String cacheKey) async {
    final cached = await _cache.read<List<dynamic>>(cacheKey);
    if (cached == null) return null;
    return cached
        .whereType<Map>()
        .map((json) => VehicleModel.fromJson(Map<String, dynamic>.from(json)))
        .toList();
  }

  Future<List<VehicleModel>> _fetchAndCacheMyVehicles(String cacheKey) async {
    try {
      final response = await _dioClient.get(ApiConstants.myVehicles);
      if (response.data is! List) return [];

      final vehicles = (response.data as List)
          .whereType<Map>()
          .map((json) => VehicleModel.fromJson(Map<String, dynamic>.from(json)))
          .toList();
      await _cache.write(cacheKey, vehicles.map((v) => v.toJson()).toList());
      return vehicles;
    } on DioException catch (e) {
      throw ServerException.fromDioException(e);
    }
  }

  Future<void> _refreshMyVehicles(String cacheKey) async {
    try {
      await _fetchAndCacheMyVehicles(cacheKey);
    } catch (_) {}
  }

  Future<void> _refreshVehicleDetail(String cacheKey, String id) async {
    try {
      final response = await _dioClient.get(ApiConstants.vehicleById(id));
      final vehicle = VehicleModel.fromJson(
        response.data as Map<String, dynamic>,
      );
      await _cache.write(cacheKey, vehicle.toJson());
    } catch (_) {}
  }
}
