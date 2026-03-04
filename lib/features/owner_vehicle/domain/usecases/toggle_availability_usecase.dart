import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/vehicle_entity.dart';
import '../repositories/owner_vehicle_repository.dart';

/// Use case for toggling vehicle availability
class ToggleAvailabilityUseCase implements UseCase<VehicleEntity, String> {
  final OwnerVehicleRepository repository;

  ToggleAvailabilityUseCase(this.repository);

  @override
  Future<Either<Failure, VehicleEntity>> call(String vehicleId) {
    return repository.toggleAvailability(vehicleId);
  }
}

