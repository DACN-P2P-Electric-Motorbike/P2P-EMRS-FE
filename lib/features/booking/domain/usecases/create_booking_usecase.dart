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

  const CreateBookingParams({
    required this.vehicleId,
    required this.startTime,
    required this.endTime,
    this.notes,
  });

  @override
  List<Object?> get props => [vehicleId, startTime, endTime, notes];
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
    );
  }
}
