import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/vehicle_entity.dart';
import '../repositories/owner_vehicle_repository.dart';
import '../../data/models/update_vehicle_params.dart';

/// Use case to update vehicle information
class UpdateVehicleUseCase
    implements UseCase<VehicleEntity, UpdateVehicleUseCaseParams> {
  final OwnerVehicleRepository repository;

  UpdateVehicleUseCase(this.repository);

  @override
  Future<Either<Failure, VehicleEntity>> call(
      UpdateVehicleUseCaseParams params) async {
    return await repository.updateVehicle(params.vehicleId, params.updateParams);
  }
}

/// Parameters for UpdateVehicleUseCase
class UpdateVehicleUseCaseParams extends Equatable {
  final String vehicleId;
  final UpdateVehicleParams updateParams;

  const UpdateVehicleUseCaseParams({
    required this.vehicleId,
    required this.updateParams,
  });

  @override
  List<Object?> get props => [vehicleId, updateParams];
}

