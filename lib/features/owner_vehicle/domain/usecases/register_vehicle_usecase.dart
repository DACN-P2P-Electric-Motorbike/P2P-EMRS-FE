import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/vehicle_entity.dart';
import '../repositories/owner_vehicle_repository.dart';
import '../../data/models/create_vehicle_params.dart';

/// Use case to register a new vehicle
class RegisterVehicleUseCase
    implements UseCase<VehicleEntity, CreateVehicleParams> {
  final OwnerVehicleRepository repository;

  RegisterVehicleUseCase(this.repository);

  @override
  Future<Either<Failure, VehicleEntity>> call(CreateVehicleParams params) async {
    return await repository.registerVehicle(params);
  }
}

