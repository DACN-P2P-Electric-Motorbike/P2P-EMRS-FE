import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/booking.dart';
import '../repositories/booking_repository.dart';

/// Parameters for creating a booking
class CreateBookingParams extends Equatable {
  final String vehicleId;
  final DateTime startTime;
  final DateTime endTime;
  final String? notes;
  final String? protectionPlan;
  final bool prepaidCharging;

  const CreateBookingParams({
    required this.vehicleId,
    required this.startTime,
    required this.endTime,
    this.notes,
    this.protectionPlan,
    this.prepaidCharging = false,
  });

  @override
  List<Object?> get props => [
    vehicleId,
    startTime,
    endTime,
    notes,
    protectionPlan,
    prepaidCharging,
  ];
}

/// Use case for creating a booking
class CreateBookingUseCase
    implements UseCase<BookingEntity, CreateBookingParams> {
  final BookingRepository _repository;

  CreateBookingUseCase(this._repository);

  @override
  Future<Either<Failure, BookingEntity>> call(
    CreateBookingParams params,
  ) async {
    return await _repository.createBooking(
      vehicleId: params.vehicleId,
      startTime: params.startTime,
      endTime: params.endTime,
      notes: params.notes,
      protectionPlan: params.protectionPlan,
      prepaidCharging: params.prepaidCharging,
    );
  }
}
