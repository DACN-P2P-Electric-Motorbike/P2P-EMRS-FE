import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/owner_vehicle_repository.dart';

/// Use case for deleting a vehicle
class DeleteVehicleUseCase implements UseCase<void, String> {
  final OwnerVehicleRepository _repository;

  DeleteVehicleUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(String vehicleId) {
    return _repository.deleteVehicle(vehicleId);
  }
}

