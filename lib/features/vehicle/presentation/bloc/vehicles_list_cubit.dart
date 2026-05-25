import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/cache/hive_cache_service.dart';
import '../../../../core/utils/vietnam_time.dart';
import '../../domain/entities/vehicle_entity.dart';
import '../../domain/usecases/get_available_vehicles.dart';
import '../../domain/usecases/get_nearby_vehicles.dart';

// States
abstract class VehicleListState extends Equatable {
  const VehicleListState();

  @override
  List<Object?> get props => [];
}

class VehicleListInitial extends VehicleListState {}

class VehicleListLoading extends VehicleListState {}

class VehicleListLoaded extends VehicleListState {
  final List<VehicleEntity> vehicles;

  const VehicleListLoaded(this.vehicles);

  @override
  List<Object?> get props => [vehicles];
}

class VehicleListError extends VehicleListState {
  final String message;

  const VehicleListError(this.message);

  @override
  List<Object?> get props => [message];
}

// Cubit
class VehicleListCubit extends Cubit<VehicleListState> {
  final GetAvailableVehicles _getAvailableVehicles;
  final GetNearbyVehicles _getNearbyVehicles;
  final HiveCacheService _cache;
  late final StreamSubscription<String> _cacheSubscription;
  String? _activeCacheKey;
  DateTime? _activeStartTime;
  DateTime? _activeEndTime;
  bool? _activeInstantBookOnly;
  VehicleCondition? _activeCondition;
  BatteryType? _activeBatteryType;
  int? _activeMinBatteryHealth;
  double? _activeNearbyLat;
  double? _activeNearbyLng;
  double? _activeNearbyRadius;

  VehicleListCubit({
    required GetAvailableVehicles getAvailableVehicles,
    required GetNearbyVehicles getNearbyVehicles,
    required HiveCacheService cache,
  }) : _getAvailableVehicles = getAvailableVehicles,
       _getNearbyVehicles = getNearbyVehicles,
       _cache = cache,
       super(VehicleListInitial()) {
    _cacheSubscription = _cache.changes.listen(_onCacheChanged);
  }

  Future<void> loadVehicles({
    DateTime? startTime,
    DateTime? endTime,
    bool? instantBookOnly,
    VehicleCondition? condition,
    BatteryType? batteryType,
    int? minBatteryHealth,
  }) async {
    emit(VehicleListLoading());

    final result = await _getAvailableVehicles(
      GetAvailableVehiclesParams(
        startTime: startTime,
        endTime: endTime,
        instantBookOnly: instantBookOnly,
        condition: condition,
        batteryType: batteryType,
        minBatteryHealth: minBatteryHealth,
      ),
    );

    result.fold((failure) => emit(VehicleListError(failure.message)), (
      vehicles,
    ) {
      _activeStartTime = startTime;
      _activeEndTime = endTime;
      _activeInstantBookOnly = instantBookOnly;
      _activeCondition = condition;
      _activeBatteryType = batteryType;
      _activeMinBatteryHealth = minBatteryHealth;
      _activeNearbyLat = null;
      _activeNearbyLng = null;
      _activeNearbyRadius = null;
      _activeCacheKey = _availableCacheKey(
        startTime,
        endTime,
        instantBookOnly,
        condition,
        batteryType,
        minBatteryHealth,
      );
      emit(VehicleListLoaded(vehicles));
    });
  }

  void filterVehicles(
    List<VehicleEntity> allVehicles, {
    String? searchQuery,
    double? maxPrice,
    VehicleBrand? brand,
    VehicleType? type,
    int? minBatteryLevel,
    VehicleCondition? condition,
    BatteryType? batteryType,
    int? minBatteryHealth,
    List<VehicleFeature>? features,
    bool instantBookOnly = false,
    String sortBy = 'default',
  }) {
    var filtered = List<VehicleEntity>.from(allVehicles);

    // Apply search filter
    if (searchQuery != null && searchQuery.isNotEmpty) {
      filtered = filtered.where((vehicle) {
        final query = searchQuery.toLowerCase();

        // Try to parse as brand
        final brandQuery = VehicleBrand.tryParse(query);
        if (brandQuery != null && vehicle.brand == brandQuery) {
          return true;
        }

        // Search in model, name, and display name
        return vehicle.model.toLowerCase().contains(query) ||
            (vehicle.name?.toLowerCase().contains(query) ?? false) ||
            vehicle.displayName.toLowerCase().contains(query) ||
            vehicle.licensePlate.toLowerCase().contains(query);
      }).toList();
    }

    // Apply brand filter
    if (brand != null) {
      filtered = filtered.where((vehicle) {
        return vehicle.brand == brand;
      }).toList();
    }

    // Apply type filter
    if (type != null) {
      filtered = filtered.where((vehicle) {
        return vehicle.type == type;
      }).toList();
    }

    // Apply price filter
    if (maxPrice != null) {
      filtered = filtered.where((vehicle) {
        return vehicle.pricePerHour <= maxPrice;
      }).toList();
    }

    // Apply battery level filter
    if (minBatteryLevel != null) {
      filtered = filtered.where((vehicle) {
        return vehicle.batteryLevel >= minBatteryLevel;
      }).toList();
    }

    if (condition != null) {
      filtered = filtered.where((vehicle) {
        return vehicle.condition == condition;
      }).toList();
    }

    if (batteryType != null) {
      filtered = filtered.where((vehicle) {
        return vehicle.batteryType == batteryType;
      }).toList();
    }

    if (minBatteryHealth != null) {
      filtered = filtered.where((vehicle) {
        return (vehicle.batteryHealth ?? 0) >= minBatteryHealth;
      }).toList();
    }

    // Apply features filter
    if (features != null && features.isNotEmpty) {
      filtered = filtered.where((vehicle) {
        // Vehicle must have all selected features
        return features.every((feature) => vehicle.features.contains(feature));
      }).toList();
    }

    if (instantBookOnly) {
      filtered = filtered.where((vehicle) => vehicle.instantBook).toList();
    }

    // Apply status filter - only show available vehicles
    filtered = filtered.where((vehicle) {
      return vehicle.isAvailable && vehicle.status == VehicleStatus.available;
    }).toList();

    // Apply sorting
    switch (sortBy) {
      case 'price_low':
        filtered.sort((a, b) => a.pricePerHour.compareTo(b.pricePerHour));
        break;
      case 'price_high':
        filtered.sort((a, b) => b.pricePerHour.compareTo(a.pricePerHour));
        break;
      case 'rating':
        filtered.sort((a, b) {
          final ratingA = a.reviewCount > 0
              ? a.totalRating / a.reviewCount
              : a.totalRating;
          final ratingB = b.reviewCount > 0
              ? b.totalRating / b.reviewCount
              : b.totalRating;
          return ratingB.compareTo(ratingA);
        });
        break;
      case 'distance':
        filtered.sort(
          (a, b) => (a.distanceFromUser ?? double.infinity).compareTo(
            b.distanceFromUser ?? double.infinity,
          ),
        );
        break;
      case 'battery_health':
        filtered.sort(
          (a, b) => (b.batteryHealth ?? -1).compareTo(a.batteryHealth ?? -1),
        );
        break;
      case 'default':
      default:
        break;
    }

    emit(VehicleListLoaded(filtered));
  }

  /// Load vehicles near a given user position within a radius.
  /// Uses server-side filtering via GET /vehicles/available?latitude=&longitude=&radiusKm=
  Future<void> loadNearbyVehicles({
    required double userLat,
    required double userLng,
    double radiusKm = 5.0,
    DateTime? startTime,
    DateTime? endTime,
    bool? instantBookOnly,
    VehicleCondition? condition,
    BatteryType? batteryType,
    int? minBatteryHealth,
  }) async {
    emit(VehicleListLoading());

    final result = await _getNearbyVehicles(
      NearbyVehicleParams(
        latitude: userLat,
        longitude: userLng,
        radiusKm: radiusKm,
        startTime: startTime,
        endTime: endTime,
        instantBookOnly: instantBookOnly,
        condition: condition,
        batteryType: batteryType,
        minBatteryHealth: minBatteryHealth,
      ),
    );

    result.fold((failure) => emit(VehicleListError(failure.message)), (
      vehicles,
    ) {
      _activeStartTime = startTime;
      _activeEndTime = endTime;
      _activeInstantBookOnly = instantBookOnly;
      _activeCondition = condition;
      _activeBatteryType = batteryType;
      _activeMinBatteryHealth = minBatteryHealth;
      _activeNearbyLat = userLat;
      _activeNearbyLng = userLng;
      _activeNearbyRadius = radiusKm;
      _activeCacheKey = _nearbyCacheKey(
        userLat,
        userLng,
        radiusKm,
        startTime,
        endTime,
        instantBookOnly,
        condition,
        batteryType,
        minBatteryHealth,
      );
      emit(VehicleListLoaded(vehicles));
    });
  }

  /// Re-filter an existing list of vehicles with a new radius.
  void updateRadius(
    List<VehicleEntity> allVehicles,
    double newRadiusKm,
    double userLat,
    double userLng,
  ) {
    final nearby = _filterByRadius(allVehicles, userLat, userLng, newRadiusKm);
    emit(VehicleListLoaded(nearby));
  }

  /// Internal helper to filter vehicles by distance and sort ascending.
  List<VehicleEntity> _filterByRadius(
    List<VehicleEntity> vehicles,
    double userLat,
    double userLng,
    double radiusKm,
  ) {
    final withLocation = vehicles.where(
      (v) => v.latitude != null && v.longitude != null,
    );

    final nearby = <VehicleEntity>[];
    for (final vehicle in withLocation) {
      final distanceMeters = Geolocator.distanceBetween(
        userLat,
        userLng,
        vehicle.latitude!,
        vehicle.longitude!,
      );
      final distanceKm = distanceMeters / 1000.0;
      if (distanceKm <= radiusKm) {
        vehicle.distanceFromUser = distanceKm;
        nearby.add(vehicle);
      }
    }

    nearby.sort(
      (a, b) => (a.distanceFromUser ?? double.infinity).compareTo(
        b.distanceFromUser ?? double.infinity,
      ),
    );

    return nearby;
  }

  void _onCacheChanged(String key) {
    if (key != _activeCacheKey || state is! VehicleListLoaded) return;
    unawaited(_reloadActiveCacheSilently());
  }

  Future<void> _reloadActiveCacheSilently() async {
    final result = _activeNearbyLat != null && _activeNearbyLng != null
        ? await _getNearbyVehicles(
            NearbyVehicleParams(
              latitude: _activeNearbyLat!,
              longitude: _activeNearbyLng!,
              radiusKm: _activeNearbyRadius ?? 5.0,
              startTime: _activeStartTime,
              endTime: _activeEndTime,
              instantBookOnly: _activeInstantBookOnly,
              condition: _activeCondition,
              batteryType: _activeBatteryType,
              minBatteryHealth: _activeMinBatteryHealth,
            ),
          )
        : await _getAvailableVehicles(
            GetAvailableVehiclesParams(
              startTime: _activeStartTime,
              endTime: _activeEndTime,
              instantBookOnly: _activeInstantBookOnly,
              condition: _activeCondition,
              batteryType: _activeBatteryType,
              minBatteryHealth: _activeMinBatteryHealth,
            ),
          );

    result.fold((_) {}, (vehicles) {
      if (!isClosed) emit(VehicleListLoaded(vehicles));
    });
  }

  String _availableCacheKey(
    DateTime? startTime,
    DateTime? endTime,
    bool? instantBookOnly,
    VehicleCondition? condition,
    BatteryType? batteryType,
    int? minBatteryHealth,
  ) {
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
    return 'vehicles.available:${_cacheSuffix(queryParameters)}';
  }

  String _nearbyCacheKey(
    double latitude,
    double longitude,
    double radius,
    DateTime? startTime,
    DateTime? endTime,
    bool? instantBookOnly,
    VehicleCondition? condition,
    BatteryType? batteryType,
    int? minBatteryHealth,
  ) {
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
    return 'vehicles.nearby:${_cacheSuffix(queryParameters)}';
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

  String _cacheSuffix(Map<String, dynamic> params) {
    if (params.isEmpty) return 'all';
    final keys = params.keys.toList()..sort();
    return keys.map((key) => '$key=${params[key]}').join('&');
  }

  @override
  Future<void> close() {
    _cacheSubscription.cancel();
    return super.close();
  }
}
