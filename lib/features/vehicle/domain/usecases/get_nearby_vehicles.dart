import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../../core/error/failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../entities/vehicle_entity.dart';
import '../repositories/vehicle_repository.dart';

class NearbyVehicleParams extends Equatable {
  final double latitude;
  final double longitude;
  final double radiusKm;
  final DateTime? startTime;
  final DateTime? endTime;

  const NearbyVehicleParams({
    required this.latitude,
    required this.longitude,
    this.radiusKm = 5.0,
    this.startTime,
    this.endTime,
  });

  @override
  List<Object?> get props => [
    latitude,
    longitude,
    radiusKm,
    startTime,
    endTime,
  ];
}

class GetNearbyVehicles
    implements UseCase<List<VehicleEntity>, NearbyVehicleParams> {
  final VehicleRepository repository;

  GetNearbyVehicles(this.repository);

  @override
  Future<Either<Failure, List<VehicleEntity>>> call(
    NearbyVehicleParams params,
  ) async {
    return await repository.getNearbyVehicles(
      latitude: params.latitude,
      longitude: params.longitude,
      radius: params.radiusKm,
      startTime: params.startTime,
      endTime: params.endTime,
    );
  }
}
