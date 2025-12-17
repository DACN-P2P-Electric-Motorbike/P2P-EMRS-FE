import 'package:dartz/dartz.dart';
import '../../../../../core/error/failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../entities/vehicle_entity.dart';
import '../repositories/vehicle_repository.dart';

class GetVehicleById implements UseCase<VehicleEntity, GetVehicleByIdParams> {
  final VehicleRepository repository;

  GetVehicleById(this.repository);

  @override
  Future<Either<Failure, VehicleEntity>> call(
    GetVehicleByIdParams params,
  ) async {
    return await repository.getVehicleById(params.id);
  }
}

class GetVehicleByIdParams {
  final String id;

  const GetVehicleByIdParams({required this.id});
}
