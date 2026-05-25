import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/vehicle_entity.dart';
import '../../data/models/availability_window_model.dart';
import '../../data/models/create_vehicle_params.dart';
import '../../data/models/update_vehicle_params.dart';

/// Abstract repository interface for owner vehicle operations
abstract class OwnerVehicleRepository {
  /// Get all vehicles owned by the current user
  Future<Either<Failure, List<VehicleEntity>>> getMyVehicles();

  /// Register a new vehicle
  Future<Either<Failure, VehicleEntity>> registerVehicle(
    CreateVehicleParams params,
  );

  /// Get vehicle by ID
  Future<Either<Failure, VehicleEntity>> getVehicleById(String id);

  /// Update vehicle information
  Future<Either<Failure, VehicleEntity>> updateVehicle(
    String id,
    UpdateVehicleParams params,
  );

  /// Toggle vehicle availability (on/off for rent)
  Future<Either<Failure, VehicleEntity>> toggleAvailability(String id);

  /// Get owner-managed availability windows for a vehicle
  Future<Either<Failure, List<VehicleAvailabilityWindowEntity>>>
  getAvailabilityWindows(String vehicleId);

  /// Create an owner-managed availability window
  Future<Either<Failure, VehicleAvailabilityWindowEntity>>
  createAvailabilityWindow(
    String vehicleId,
    CreateAvailabilityWindowParams params,
  );

  /// Update an owner-managed availability window
  Future<Either<Failure, VehicleAvailabilityWindowEntity>>
  updateAvailabilityWindow(
    String vehicleId,
    String windowId,
    CreateAvailabilityWindowParams params,
  );

  /// Delete an owner-managed availability window
  Future<Either<Failure, void>> deleteAvailabilityWindow(
    String vehicleId,
    String windowId,
  );

  /// Delete a vehicle
  Future<Either<Failure, void>> deleteVehicle(String id);
}
