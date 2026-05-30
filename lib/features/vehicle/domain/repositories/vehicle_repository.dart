import 'package:dartz/dartz.dart';
import 'package:fe_capstone_project/features/vehicle/domain/entities/vehicle_entity.dart';
import '../entities/availability_summary.dart';
import '../entities/vehicle_page.dart';
import '../../../../core/error/failures.dart';

/// Repository interface for vehicle operations (renter side)
abstract class VehicleRepository {
  /// Get all available vehicles
  Future<Either<Failure, VehiclePage>> getAvailableVehicles({
    DateTime? startTime,
    DateTime? endTime,
    bool? instantBookOnly,
    VehicleCondition? condition,
    BatteryType? batteryType,
    int? minBatteryHealth,
    int? limit,
    int? offset,
  });

  /// Get vehicle by ID
  Future<Either<Failure, VehicleEntity>> getVehicleById(String id);

  /// Get renter-visible configured availability rules.
  Future<Either<Failure, VehicleAvailabilitySummary>> getAvailabilitySummary(
    String id,
  );

  /// Search vehicles with filters
  Future<Either<Failure, List<VehicleEntity>>> searchVehicles({
    String? brand,
    String? model,
    double? maxPrice,
    double? latitude,
    double? longitude,
    double? radius,
  });

  /// Get nearby vehicles
  Future<Either<Failure, VehiclePage>> getNearbyVehicles({
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

  /// Save/bookmark a vehicle
  Future<Either<Failure, void>> saveVehicle(String vehicleId);

  /// Remove saved vehicle
  Future<Either<Failure, void>> removeSavedVehicle(String vehicleId);

  /// Get saved vehicles
  Future<Either<Failure, List<VehicleEntity>>> getSavedVehicles();
}
