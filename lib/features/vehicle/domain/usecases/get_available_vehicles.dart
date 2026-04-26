import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:fe_capstone_project/features/vehicle/domain/entities/vehicle_entity.dart';
import '../../../../../core/error/failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../repositories/vehicle_repository.dart';

class GetAvailableVehiclesParams extends Equatable {
  final DateTime? startTime;
  final DateTime? endTime;

  const GetAvailableVehiclesParams({this.startTime, this.endTime});

  @override
  List<Object?> get props => [startTime, endTime];
}

class GetAvailableVehicles
    implements UseCase<List<VehicleEntity>, GetAvailableVehiclesParams> {
  final VehicleRepository repository;

  GetAvailableVehicles(this.repository);

  @override
  Future<Either<Failure, List<VehicleEntity>>> call(
    GetAvailableVehiclesParams params,
  ) async {
    return await repository.getAvailableVehicles(
      startTime: params.startTime,
      endTime: params.endTime,
    );
  }
}
