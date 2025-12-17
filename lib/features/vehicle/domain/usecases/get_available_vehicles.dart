import 'package:dartz/dartz.dart';
import 'package:fe_capstone_project/features/vehicle/domain/entities/vehicle_entity.dart';
import '../../../../../core/error/failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../repositories/vehicle_repository.dart';

class GetAvailableVehicles implements UseCase<List<VehicleEntity>, NoParams> {
  final VehicleRepository repository;

  GetAvailableVehicles(this.repository);

  @override
  Future<Either<Failure, List<VehicleEntity>>> call(NoParams params) async {
    return await repository.getAvailableVehicles();
  }
}
