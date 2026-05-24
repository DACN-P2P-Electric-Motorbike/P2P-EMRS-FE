import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/handover.dart';
import '../repositories/handover_repository.dart';

class HandoverMutationParams {
  final String bookingId;
  final List<HandoverPhotoInput> photos;
  final double? odometerReading;
  final int? batteryLevel;
  final int? fuelLevel;
  final double? latitude;
  final double? longitude;
  final String? notes;

  const HandoverMutationParams({
    required this.bookingId,
    required this.photos,
    this.odometerReading,
    this.batteryLevel,
    this.fuelLevel,
    this.latitude,
    this.longitude,
    this.notes,
  });
}

class CreateCheckInUseCase
    implements UseCase<VehicleHandover, HandoverMutationParams> {
  final HandoverRepository repository;
  CreateCheckInUseCase(this.repository);

  @override
  Future<Either<Failure, VehicleHandover>> call(HandoverMutationParams params) {
    return repository.createCheckIn(
      bookingId: params.bookingId,
      photos: params.photos,
      odometerReading: params.odometerReading,
      batteryLevel: params.batteryLevel,
      fuelLevel: params.fuelLevel,
      latitude: params.latitude,
      longitude: params.longitude,
      notes: params.notes,
    );
  }
}

class CreateCheckOutUseCase
    implements UseCase<VehicleHandover, HandoverMutationParams> {
  final HandoverRepository repository;
  CreateCheckOutUseCase(this.repository);

  @override
  Future<Either<Failure, VehicleHandover>> call(HandoverMutationParams params) {
    return repository.createCheckOut(
      bookingId: params.bookingId,
      photos: params.photos,
      odometerReading: params.odometerReading,
      batteryLevel: params.batteryLevel,
      fuelLevel: params.fuelLevel,
      latitude: params.latitude,
      longitude: params.longitude,
      notes: params.notes,
    );
  }
}

class GetHandoverByBookingParams {
  final String bookingId;
  const GetHandoverByBookingParams(this.bookingId);
}

class GetHandoverByBookingUseCase
    implements UseCase<HandoverSummary, GetHandoverByBookingParams> {
  final HandoverRepository repository;
  GetHandoverByBookingUseCase(this.repository);

  @override
  Future<Either<Failure, HandoverSummary>> call(
    GetHandoverByBookingParams params,
  ) {
    return repository.getByBooking(params.bookingId);
  }
}

class ConfirmHandoverParams {
  final String handoverId;
  const ConfirmHandoverParams(this.handoverId);
}

class ConfirmHandoverUseCase
    implements UseCase<VehicleHandover, ConfirmHandoverParams> {
  final HandoverRepository repository;
  ConfirmHandoverUseCase(this.repository);

  @override
  Future<Either<Failure, VehicleHandover>> call(ConfirmHandoverParams params) {
    return repository.confirm(params.handoverId);
  }
}
