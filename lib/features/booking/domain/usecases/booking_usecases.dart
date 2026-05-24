import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/booking.dart';
import '../entities/booking_lock.dart';
import '../entities/cancellation_refund_preview.dart';
import '../repositories/booking_repository.dart';

/// Create booking lock use case
class CreateBookingLockParams extends Equatable {
  final String vehicleId;
  final DateTime startTime;
  final DateTime endTime;

  const CreateBookingLockParams({
    required this.vehicleId,
    required this.startTime,
    required this.endTime,
  });

  @override
  List<Object?> get props => [vehicleId, startTime, endTime];
}

class CreateBookingLockUseCase
    implements UseCase<BookingLock, CreateBookingLockParams> {
  final BookingRepository _repository;

  CreateBookingLockUseCase(this._repository);

  @override
  Future<Either<Failure, BookingLock>> call(
    CreateBookingLockParams params,
  ) async {
    return await _repository.createBookingLock(
      vehicleId: params.vehicleId,
      startTime: params.startTime,
      endTime: params.endTime,
    );
  }
}

/// Release booking lock use case
class ReleaseBookingLockParams extends Equatable {
  final String lockId;

  const ReleaseBookingLockParams(this.lockId);

  @override
  List<Object?> get props => [lockId];
}

class ReleaseBookingLockUseCase
    implements UseCase<void, ReleaseBookingLockParams> {
  final BookingRepository _repository;

  ReleaseBookingLockUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(ReleaseBookingLockParams params) async {
    return await _repository.releaseBookingLock(params.lockId);
  }
}

/// Get renter bookings use case
class GetRenterBookingsParams extends Equatable {
  final BookingStatus? status;

  const GetRenterBookingsParams({this.status});

  @override
  List<Object?> get props => [status];
}

class GetRenterBookingsUseCase
    implements UseCase<List<BookingEntity>, GetRenterBookingsParams> {
  final BookingRepository _repository;

  GetRenterBookingsUseCase(this._repository);

  @override
  Future<Either<Failure, List<BookingEntity>>> call(
    GetRenterBookingsParams params,
  ) async {
    return await _repository.getRenterBookings(status: params.status);
  }
}

/// Get booking by ID use case
class GetBookingByIdParams extends Equatable {
  final String bookingId;

  const GetBookingByIdParams(this.bookingId);

  @override
  List<Object> get props => [bookingId];
}

class GetBookingByIdUseCase
    implements UseCase<BookingEntity, GetBookingByIdParams> {
  final BookingRepository _repository;

  GetBookingByIdUseCase(this._repository);

  @override
  Future<Either<Failure, BookingEntity>> call(
    GetBookingByIdParams params,
  ) async {
    return await _repository.getBookingById(params.bookingId);
  }
}

/// Cancel booking use case
class CancelBookingParams extends Equatable {
  final String bookingId;
  final String reason;

  const CancelBookingParams({required this.bookingId, required this.reason});

  @override
  List<Object> get props => [bookingId, reason];
}

class CancelBookingUseCase
    implements UseCase<BookingEntity, CancelBookingParams> {
  final BookingRepository _repository;

  CancelBookingUseCase(this._repository);

  @override
  Future<Either<Failure, BookingEntity>> call(
    CancelBookingParams params,
  ) async {
    return await _repository.cancelBooking(params.bookingId, params.reason);
  }
}

/// Preview cancellation refund policy use case
class GetCancellationRefundPreviewParams extends Equatable {
  final String bookingId;

  const GetCancellationRefundPreviewParams(this.bookingId);

  @override
  List<Object> get props => [bookingId];
}

class GetCancellationRefundPreviewUseCase
    implements
        UseCase<CancellationRefundPreview, GetCancellationRefundPreviewParams> {
  final BookingRepository _repository;

  GetCancellationRefundPreviewUseCase(this._repository);

  @override
  Future<Either<Failure, CancellationRefundPreview>> call(
    GetCancellationRefundPreviewParams params,
  ) async {
    return _repository.getCancellationRefundPreview(params.bookingId);
  }
}

/// Approve booking use case (owner)
class ApproveBookingParams extends Equatable {
  final String bookingId;
  final String? message;

  const ApproveBookingParams({required this.bookingId, this.message});

  @override
  List<Object?> get props => [bookingId, message];
}

class ApproveBookingUseCase
    implements UseCase<BookingEntity, ApproveBookingParams> {
  final BookingRepository _repository;

  ApproveBookingUseCase(this._repository);

  @override
  Future<Either<Failure, BookingEntity>> call(
    ApproveBookingParams params,
  ) async {
    return await _repository.approveBooking(
      params.bookingId,
      message: params.message,
    );
  }
}

/// Reject booking use case (owner)
class RejectBookingParams extends Equatable {
  final String bookingId;
  final String reason;

  const RejectBookingParams({required this.bookingId, required this.reason});

  @override
  List<Object> get props => [bookingId, reason];
}

class RejectBookingUseCase
    implements UseCase<BookingEntity, RejectBookingParams> {
  final BookingRepository _repository;

  RejectBookingUseCase(this._repository);

  @override
  Future<Either<Failure, BookingEntity>> call(
    RejectBookingParams params,
  ) async {
    return await _repository.rejectBooking(params.bookingId, params.reason);
  }
}

/// Get owner bookings use case
class GetOwnerBookingsParams extends Equatable {
  final BookingStatus? status;

  const GetOwnerBookingsParams({this.status});

  @override
  List<Object?> get props => [status];
}

class GetOwnerBookingsUseCase
    implements UseCase<List<BookingEntity>, GetOwnerBookingsParams> {
  final BookingRepository _repository;

  GetOwnerBookingsUseCase(this._repository);

  @override
  Future<Either<Failure, List<BookingEntity>>> call(
    GetOwnerBookingsParams params,
  ) async {
    return await _repository.getOwnerBookings(status: params.status);
  }
}

/// Get pending bookings use case (owner)
class GetPendingBookingsUseCase
    implements UseCase<List<BookingEntity>, NoParams> {
  final BookingRepository _repository;

  GetPendingBookingsUseCase(this._repository);

  @override
  Future<Either<Failure, List<BookingEntity>>> call(NoParams params) async {
    return await _repository.getPendingBookings();
  }
}
