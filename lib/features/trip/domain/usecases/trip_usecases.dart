import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/trip_entity.dart';
import '../repositories/trip_repository.dart';

class StartTripParams {
  final String bookingId;
  final double? startLatitude;
  final double? startLongitude;
  final String? startAddress;
  final double? startBattery;

  const StartTripParams({
    required this.bookingId,
    this.startLatitude,
    this.startLongitude,
    this.startAddress,
    this.startBattery,
  });
}

class EndTripParams {
  final String tripId;
  final double? endLatitude;
  final double? endLongitude;
  final String? endAddress;
  final double? endBattery;
  final bool hasIssues;
  final String? issueDescription;

  const EndTripParams({
    required this.tripId,
    this.endLatitude,
    this.endLongitude,
    this.endAddress,
    this.endBattery,
    this.hasIssues = false,
    this.issueDescription,
  });
}

class StartTripUseCase implements UseCase<TripEntity, StartTripParams> {
  final TripRepository repository;
  StartTripUseCase(this.repository);

  @override
  Future<Either<Failure, TripEntity>> call(StartTripParams params) {
    return repository.startTrip(
      bookingId: params.bookingId,
      startLatitude: params.startLatitude,
      startLongitude: params.startLongitude,
      startAddress: params.startAddress,
      startBattery: params.startBattery,
    );
  }
}

class EndTripUseCase implements UseCase<TripEntity, EndTripParams> {
  final TripRepository repository;
  EndTripUseCase(this.repository);

  @override
  Future<Either<Failure, TripEntity>> call(EndTripParams params) {
    return repository.endTrip(
      tripId: params.tripId,
      endLatitude: params.endLatitude,
      endLongitude: params.endLongitude,
      endAddress: params.endAddress,
      endBattery: params.endBattery,
      hasIssues: params.hasIssues,
      issueDescription: params.issueDescription,
    );
  }
}

class GetActiveTripUseCase implements UseCase<TripEntity?, NoParams> {
  final TripRepository repository;
  GetActiveTripUseCase(this.repository);

  @override
  Future<Either<Failure, TripEntity?>> call(NoParams params) {
    return repository.getActiveTrip();
  }
}

class GetTripHistoryUseCase implements UseCase<List<TripEntity>, NoParams> {
  final TripRepository repository;
  GetTripHistoryUseCase(this.repository);

  @override
  Future<Either<Failure, List<TripEntity>>> call(NoParams params) {
    return repository.getTripHistory();
  }
}

class GetTripByIdParams {
  final String tripId;
  const GetTripByIdParams(this.tripId);
}

class GetTripByIdUseCase implements UseCase<TripEntity, GetTripByIdParams> {
  final TripRepository repository;
  GetTripByIdUseCase(this.repository);

  @override
  Future<Either<Failure, TripEntity>> call(GetTripByIdParams params) {
    return repository.getTripById(params.tripId);
  }
}
