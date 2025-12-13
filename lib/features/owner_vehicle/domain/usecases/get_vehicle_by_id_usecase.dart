import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/vehicle_entity.dart';
import '../repositories/owner_vehicle_repository.dart';

/// Use case to get a vehicle by ID
class GetVehicleByIdUseCase implements UseCase<VehicleEntity, String> {
  final OwnerVehicleRepository repository;

  GetVehicleByIdUseCase(this.repository);

  @override
  Future<Either<Failure, VehicleEntity>> call(String id) async {
    return await repository.getVehicleById(id);
  }
}

