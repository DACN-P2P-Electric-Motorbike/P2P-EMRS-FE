import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/vehicle_entity.dart';
import '../../data/models/create_vehicle_params.dart';
import '../../data/models/update_vehicle_params.dart';

/// Abstract repository interface for owner vehicle operations
abstract class OwnerVehicleRepository {
  /// Get all vehicles owned by the current user
  Future<Either<Failure, List<VehicleEntity>>> getMyVehicles();

  /// Register a new vehicle
  Future<Either<Failure, VehicleEntity>> registerVehicle(
      CreateVehicleParams params);

  /// Get vehicle by ID
  Future<Either<Failure, VehicleEntity>> getVehicleById(String id);

  /// Update vehicle information
  Future<Either<Failure, VehicleEntity>> updateVehicle(
      String id, UpdateVehicleParams params);

  /// Delete a vehicle
  Future<Either<Failure, void>> deleteVehicle(String id);
}

