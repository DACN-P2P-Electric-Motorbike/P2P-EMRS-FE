import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/handover.dart';

abstract class HandoverRepository {
  Future<Either<Failure, VehicleHandover>> createCheckIn({
    required String bookingId,
    required List<HandoverPhotoInput> photos,
    double? odometerReading,
    int? batteryLevel,
    int? fuelLevel,
    double? latitude,
    double? longitude,
    String? notes,
  });

  Future<Either<Failure, VehicleHandover>> createCheckOut({
    required String bookingId,
    required List<HandoverPhotoInput> photos,
    double? odometerReading,
    int? batteryLevel,
    int? fuelLevel,
    double? latitude,
    double? longitude,
    String? notes,
  });

  Future<Either<Failure, HandoverSummary>> getByBooking(String bookingId);

  Future<Either<Failure, VehicleHandover>> confirm(String handoverId);
}
