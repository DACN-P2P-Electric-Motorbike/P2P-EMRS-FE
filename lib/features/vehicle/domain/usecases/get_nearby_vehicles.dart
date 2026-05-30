import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../../core/error/failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../entities/vehicle_entity.dart';
import '../entities/vehicle_page.dart';
import '../repositories/vehicle_repository.dart';

class NearbyVehicleParams extends Equatable {
  final double latitude;
  final double longitude;
  final double radiusKm;
  final DateTime? startTime;
  final DateTime? endTime;
  final bool? instantBookOnly;
  final VehicleCondition? condition;
  final BatteryType? batteryType;
  final int? minBatteryHealth;
  final int? limit;
  final int? offset;

  const NearbyVehicleParams({
    required this.latitude,
    required this.longitude,
    this.radiusKm = 50.0,
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
    latitude,
    longitude,
    radiusKm,
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

class GetNearbyVehicles
    implements UseCase<VehiclePage, NearbyVehicleParams> {
  final VehicleRepository repository;

  GetNearbyVehicles(this.repository);

  @override
  Future<Either<Failure, VehiclePage>> call(
    NearbyVehicleParams params,
  ) async {
    return await repository.getNearbyVehicles(
      latitude: params.latitude,
      longitude: params.longitude,
      radius: params.radiusKm,
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
