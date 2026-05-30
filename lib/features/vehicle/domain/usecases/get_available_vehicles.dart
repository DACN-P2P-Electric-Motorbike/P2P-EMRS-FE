import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:fe_capstone_project/features/vehicle/domain/entities/vehicle_entity.dart';
import 'package:fe_capstone_project/features/vehicle/domain/entities/vehicle_page.dart';
import '../../../../../core/error/failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../repositories/vehicle_repository.dart';

class GetAvailableVehiclesParams extends Equatable {
  final DateTime? startTime;
  final DateTime? endTime;
  final bool? instantBookOnly;
  final VehicleCondition? condition;
  final BatteryType? batteryType;
  final int? minBatteryHealth;
  final int? limit;
  final int? offset;

  const GetAvailableVehiclesParams({
    this.startTime,
    this.endTime,
    this.instantBookOnly,
    this.condition,
    this.batteryType,
    this.minBatteryHealth,
    this.limit,
    this.offset,
  });

  @override
  List<Object?> get props => [
    startTime,
    endTime,
    instantBookOnly,
    condition,
    batteryType,
    minBatteryHealth,
    limit,
    offset,
  ];
}

class GetAvailableVehicles
    implements UseCase<VehiclePage, GetAvailableVehiclesParams> {
  final VehicleRepository repository;

  GetAvailableVehicles(this.repository);

  @override
  Future<Either<Failure, VehiclePage>> call(
    GetAvailableVehiclesParams params,
  ) async {
    return await repository.getAvailableVehicles(
      startTime: params.startTime,
      endTime: params.endTime,
      instantBookOnly: params.instantBookOnly,
      condition: params.condition,
      batteryType: params.batteryType,
      minBatteryHealth: params.minBatteryHealth,
      limit: params.limit,
      offset: params.offset,
    );
  }
}
