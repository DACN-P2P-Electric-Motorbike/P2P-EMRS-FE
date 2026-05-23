import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../data/models/availability_window_model.dart';
import '../entities/vehicle_entity.dart';
import '../repositories/owner_vehicle_repository.dart';

class GetVehicleAvailabilityUseCase
    implements UseCase<List<VehicleAvailabilityWindowEntity>, String> {
  final OwnerVehicleRepository repository;

  GetVehicleAvailabilityUseCase(this.repository);

  @override
  Future<Either<Failure, List<VehicleAvailabilityWindowEntity>>> call(
    String vehicleId,
  ) {
    return repository.getAvailabilityWindows(vehicleId);
  }
}

class CreateVehicleAvailabilityUseCase
    implements
        UseCase<
          VehicleAvailabilityWindowEntity,
          CreateVehicleAvailabilityParams
        > {
  final OwnerVehicleRepository repository;

  CreateVehicleAvailabilityUseCase(this.repository);

  @override
  Future<Either<Failure, VehicleAvailabilityWindowEntity>> call(
    CreateVehicleAvailabilityParams params,
  ) {
    return repository.createAvailabilityWindow(
      params.vehicleId,
      params.windowParams,
    );
  }
}

class CreateVehicleAvailabilityParams extends Equatable {
  final String vehicleId;
  final CreateAvailabilityWindowParams windowParams;

  const CreateVehicleAvailabilityParams({
    required this.vehicleId,
    required this.windowParams,
  });

  @override
  List<Object?> get props => [vehicleId, windowParams];
}

class DeleteVehicleAvailabilityUseCase
    implements UseCase<void, DeleteVehicleAvailabilityParams> {
  final OwnerVehicleRepository repository;

  DeleteVehicleAvailabilityUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteVehicleAvailabilityParams params) {
    return repository.deleteAvailabilityWindow(
      params.vehicleId,
      params.windowId,
    );
  }
}

class DeleteVehicleAvailabilityParams extends Equatable {
  final String vehicleId;
  final String windowId;

  const DeleteVehicleAvailabilityParams({
    required this.vehicleId,
    required this.windowId,
  });

  @override
  List<Object?> get props => [vehicleId, windowId];
}
