import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/vehicle_entity.dart';
import '../repositories/owner_vehicle_repository.dart';

/// Use case to get all vehicles owned by current user
class GetMyVehiclesUseCase implements UseCase<List<VehicleEntity>, NoParams> {
  final OwnerVehicleRepository repository;

  GetMyVehiclesUseCase(this.repository);

  @override
  Future<Either<Failure, List<VehicleEntity>>> call(NoParams params) async {
    return await repository.getMyVehicles();
  }
}

