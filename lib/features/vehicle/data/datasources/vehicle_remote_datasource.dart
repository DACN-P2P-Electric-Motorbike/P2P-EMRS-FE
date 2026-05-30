import 'dart:async';

import 'package:dio/dio.dart';
import '../../../../../core/constants/api_constants.dart';
import '../../../../../core/cache/hive_cache_service.dart';
import '../../../../../core/error/exceptions.dart';
import '../../../../../core/network/dio_client.dart';
import '../../../../../core/utils/vietnam_time.dart';
import '../models/vehicle_model.dart';
import '../models/availability_summary_model.dart';
import '../../domain/entities/vehicle_entity.dart';

/// Remote data source for vehicle operations
abstract class VehicleRemoteDataSource {
  Future<VehiclePageModel> getAvailableVehicles({
    DateTime? startTime,
    DateTime? endTime,
    bool? instantBookOnly,
    VehicleCondition? condition,
    BatteryType? batteryType,
    int? minBatteryHealth,
    int? limit,
    int? offset,
  });
  Future<VehicleModel> getVehicleById(String id);
  Future<VehicleAvailabilitySummaryModel> getAvailabilitySummary(String id);
  Future<List<VehicleModel>> searchVehicles({
    String? brand,
    String? model,
    double? maxPrice,
    double? latitude,
    double? longitude,
    double? radius,
  });
  Future<VehiclePageModel> getNearbyVehicles({
    required double latitude,
    required double longitude,
    double radius = 50.0,
    DateTime? startTime,
    DateTime? endTime,
    bool? instantBookOnly,
    VehicleCondition? condition,
    BatteryType? batteryType,
    int? minBatteryHealth,
    int? limit,
    int? offset,
  });
}

class VehiclePageModel {
  final List<VehicleModel> vehicles;
  final int total;

  const VehiclePageModel({required this.vehicles, required this.total});
}

class VehicleRemoteDataSourceImpl implements VehicleRemoteDataSource {
  final DioClient _dioClient;
  final HiveCacheService _cache;

  VehicleRemoteDataSourceImpl({
    required DioClient dioClient,
    required HiveCacheService cache,
  }) : _dioClient = dioClient,
       _cache = cache;

  @override
  Future<VehiclePageModel> getAvailableVehicles({
    DateTime? startTime,
    DateTime? endTime,
    bool? instantBookOnly,
    VehicleCondition? condition,
    BatteryType? batteryType,
    int? minBatteryHealth,
    int? limit,
    int? offset,
  }) async {
    final queryParameters = _availabilityQuery(
      startTime,
      endTime,
      instantBookOnly,
      condition: condition,
      batteryType: batteryType,
      minBatteryHealth: minBatteryHealth,
    );
    if (limit != null) queryParameters['limit'] = limit;
    if (offset != null) queryParameters['offset'] = offset;
    final cacheKey = 'vehicles.available:${_cacheSuffix(queryParameters)}';
    final cached = await _cachedVehiclePage(cacheKey);
    if (cached != null) {
      unawaited(_refreshVehicleList(cacheKey, queryParameters));
      return cached;
    }

    return _fetchAndCacheVehicleList(cacheKey, queryParameters);
  }

  @override
  Future<VehicleModel> getVehicleById(String id) async {
    final cacheKey = 'vehicles.detail:$id';
    final cached = await _cache.read<Map<dynamic, dynamic>>(cacheKey);
    if (cached != null) {
      unawaited(_refreshVehicleDetail(cacheKey, id));
      return VehicleModel.fromJson(Map<String, dynamic>.from(cached));
    }

    try {
      final response = await _dioClient.get(ApiConstants.vehicleById(id));
      final data = Map<String, dynamic>.from(response.data as Map);
      final vehicle = VehicleModel.fromJson(data);
      await _cache.write(cacheKey, vehicle.toJson());
      return vehicle;
    } on DioException catch (e) {
      throw ServerException.fromDioException(e);
    }
  }

  @override
  Future<VehicleAvailabilitySummaryModel> getAvailabilitySummary(
    String id,
  ) async {
    try {
      final response = await _dioClient.get(
        ApiConstants.vehicleAvailabilitySummary(id),
      );
      return VehicleAvailabilitySummaryModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return const VehicleAvailabilitySummaryModel(
          hasAvailableCalendar: false,
          rules: [],
        );
      }
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
    final queryParameters = <String, dynamic>{};
    if (brand != null) queryParameters['brand'] = brand;
    if (model != null) queryParameters['model'] = model;
    if (maxPrice != null) queryParameters['maxPrice'] = maxPrice;
    if (latitude != null) queryParameters['latitude'] = latitude;
    if (longitude != null) queryParameters['longitude'] = longitude;
    if (radius != null) queryParameters['radius'] = radius;

    final cacheKey = 'vehicles.search:${_cacheSuffix(queryParameters)}';
    final cached = await _cachedVehicleList(cacheKey);
    if (cached != null) {
      unawaited(_refreshSearchVehicleList(cacheKey, queryParameters));
      return cached;
    }

    return _fetchAndCacheSearchList(cacheKey, queryParameters);
  }

  @override
  Future<VehiclePageModel> getNearbyVehicles({
    required double latitude,
    required double longitude,
    double radius = 50.0,
    DateTime? startTime,
    DateTime? endTime,
    bool? instantBookOnly,
    VehicleCondition? condition,
    BatteryType? batteryType,
    int? minBatteryHealth,
    int? limit,
    int? offset,
  }) async {
    final queryParameters = <String, dynamic>{
      'latitude': latitude,
      'longitude': longitude,
      'radiusKm': radius,
    };
    if (startTime != null) {
      queryParameters['startTime'] = VietnamTime.toApiIsoString(startTime);
    }
    if (endTime != null) {
      queryParameters['endTime'] = VietnamTime.toApiIsoString(endTime);
    }
    if (instantBookOnly == true) queryParameters['instantBook'] = true;
    _appendEvMetadataQuery(
      queryParameters,
      condition: condition,
      batteryType: batteryType,
      minBatteryHealth: minBatteryHealth,
    );
    if (limit != null) queryParameters['limit'] = limit;
    if (offset != null) queryParameters['offset'] = offset;

    final cacheKey = 'vehicles.nearby:${_cacheSuffix(queryParameters)}';
    final cached = await _cachedVehiclePage(cacheKey);
    if (cached != null) {
      unawaited(_refreshVehicleList(cacheKey, queryParameters));
      return cached;
    }

    return _fetchAndCacheVehicleList(cacheKey, queryParameters);
  }

  Map<String, dynamic> _availabilityQuery(
    DateTime? startTime,
    DateTime? endTime,
    bool? instantBookOnly, {
    VehicleCondition? condition,
    BatteryType? batteryType,
    int? minBatteryHealth,
  }) {
    final queryParameters = <String, dynamic>{};
    if (startTime != null) {
      queryParameters['startTime'] = VietnamTime.toApiIsoString(startTime);
    }
    if (endTime != null) {
      queryParameters['endTime'] = VietnamTime.toApiIsoString(endTime);
    }
    if (instantBookOnly == true) queryParameters['instantBook'] = true;
    _appendEvMetadataQuery(
      queryParameters,
      condition: condition,
      batteryType: batteryType,
      minBatteryHealth: minBatteryHealth,
    );
    return queryParameters;
  }

  void _appendEvMetadataQuery(
    Map<String, dynamic> queryParameters, {
    VehicleCondition? condition,
    BatteryType? batteryType,
    int? minBatteryHealth,
  }) {
    if (condition != null) {
      queryParameters['condition'] = condition.toApiString();
    }
    if (batteryType != null) {
      queryParameters['batteryType'] = batteryType.toApiString();
    }
    if (minBatteryHealth != null) {
      queryParameters['minBatteryHealth'] = minBatteryHealth;
    }
  }

  Future<VehiclePageModel?> _cachedVehiclePage(String cacheKey) async {
    final cached = await _cache.read<Map<dynamic, dynamic>>(cacheKey);
    if (cached == null) return null;
    final vehicles = (cached['vehicles'] as List? ?? const [])
        .whereType<Map>()
        .map((json) => VehicleModel.fromJson(Map<String, dynamic>.from(json)))
        .toList();
    return VehiclePageModel(
      vehicles: vehicles,
      total: cached['total'] is int ? cached['total'] as int : vehicles.length,
    );
  }

  Future<List<VehicleModel>?> _cachedVehicleList(String cacheKey) async {
    final cached = await _cache.read<List<dynamic>>(cacheKey);
    if (cached == null) return null;
    return cached
        .whereType<Map>()
        .map((json) => VehicleModel.fromJson(Map<String, dynamic>.from(json)))
        .toList();
  }

  Future<VehiclePageModel> _fetchAndCacheVehicleList(
    String cacheKey,
    Map<String, dynamic> queryParameters,
  ) async {
    try {
      final response = await _dioClient.get(
        ApiConstants.availableVehicles,
        queryParameters: queryParameters,
      );

      final page = _vehiclePageFromEnvelope(response.data);
      await _cache.write(cacheKey, {
        'vehicles': page.vehicles.map((v) => v.toJson()).toList(),
        'total': page.total,
      });
      return page;
    } on DioException catch (e) {
      throw ServerException.fromDioException(e);
    }
  }

  Future<List<VehicleModel>> _fetchAndCacheSearchList(
    String cacheKey,
    Map<String, dynamic> queryParameters,
  ) async {
    try {
      final response = await _dioClient.get(
        '${ApiConstants.vehicles}/search',
        queryParameters: queryParameters,
      );

      if (response.data is! List) {
        throw const ServerException(message: 'Invalid response format');
      }

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

  VehiclePageModel _vehiclePageFromEnvelope(dynamic data) {
    if (data is Map<String, dynamic> && data['vehicles'] is List) {
      final vehicles = (data['vehicles'] as List)
          .whereType<Map>()
          .map((json) => VehicleModel.fromJson(Map<String, dynamic>.from(json)))
          .toList();
      return VehiclePageModel(
        vehicles: vehicles,
        total: data['total'] is int ? data['total'] as int : vehicles.length,
      );
    }

    throw const ServerException(message: 'Invalid response format');
  }

  Future<void> _refreshVehicleList(
    String cacheKey,
    Map<String, dynamic> queryParameters,
  ) async {
    try {
      await _fetchAndCacheVehicleList(cacheKey, queryParameters);
    } catch (_) {}
  }

  Future<void> _refreshSearchVehicleList(
    String cacheKey,
    Map<String, dynamic> queryParameters,
  ) async {
    try {
      await _fetchAndCacheSearchList(cacheKey, queryParameters);
    } catch (_) {}
  }

  Future<void> _refreshVehicleDetail(String cacheKey, String id) async {
    try {
      final response = await _dioClient.get(ApiConstants.vehicleById(id));
      final vehicle = VehicleModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
      await _cache.write(cacheKey, vehicle.toJson());
    } catch (_) {}
  }

  String _cacheSuffix(Map<String, dynamic> params) {
    if (params.isEmpty) return 'all';
    final keys = params.keys.toList()..sort();
    return keys.map((key) => '$key=${params[key]}').join('&');
  }
}
