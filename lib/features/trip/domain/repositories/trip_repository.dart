import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/trip_entity.dart';

abstract class TripRepository {
  Future<Either<Failure, TripEntity>> startTrip({
    required String bookingId,
    double? startLatitude,
    double? startLongitude,
    String? startAddress,
    double? startBattery,
  });

  Future<Either<Failure, TripEntity>> endTrip({
    required String tripId,
    double? endLatitude,
    double? endLongitude,
    String? endAddress,
    double? endBattery,
    bool hasIssues = false,
    String? issueDescription,
  });

  Future<Either<Failure, TripEntity?>> getActiveTrip();

  Future<Either<Failure, List<TripEntity>>> getTripHistory();

  Future<Either<Failure, TripEntity>> getTripById(String tripId);
}
