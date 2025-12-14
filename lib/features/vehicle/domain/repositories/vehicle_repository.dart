import 'package:dartz/dartz.dart';
import 'package:fe_capstone_project/features/vehicle/domain/entities/vehicle_entity.dart';
import '../../../../core/error/failures.dart';

/// Repository interface for vehicle operations (renter side)
abstract class VehicleRepository {
  /// Get all available vehicles
  Future<Either<Failure, List<VehicleEntity>>> getAvailableVehicles();

  /// Get vehicle by ID
  Future<Either<Failure, VehicleEntity>> getVehicleById(String id);

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
  Future<Either<Failure, List<VehicleEntity>>> getNearbyVehicles({
    required double latitude,
    required double longitude,
    double radius = 5.0,
  });

  /// Save/bookmark a vehicle
  Future<Either<Failure, void>> saveVehicle(String vehicleId);

  /// Remove saved vehicle
  Future<Either<Failure, void>> removeSavedVehicle(String vehicleId);

  /// Get saved vehicles
  Future<Either<Failure, List<VehicleEntity>>> getSavedVehicles();
}
