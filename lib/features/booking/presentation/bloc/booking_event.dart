import 'package:equatable/equatable.dart';
import '../../domain/entities/booking.dart';

/// Base class for booking events
abstract class BookingEvent extends Equatable {
  const BookingEvent();

  @override
  List<Object?> get props => [];
}

/// Create booking event
class CreateBookingEvent extends BookingEvent {
  final String vehicleId;
  final DateTime startTime;
  final DateTime endTime;
  final String? notes;

  const CreateBookingEvent({
    required this.vehicleId,
    required this.startTime,
    required this.endTime,
    this.notes,
  });

  @override
  List<Object?> get props => [vehicleId, startTime, endTime, notes];
}

/// Load renter bookings event
class LoadRenterBookingsEvent extends BookingEvent {
  final BookingStatus? status;

  const LoadRenterBookingsEvent({this.status});

  @override
  List<Object?> get props => [status];
}

/// Load owner bookings event
class LoadOwnerBookingsEvent extends BookingEvent {
  final BookingStatus? status;

  const LoadOwnerBookingsEvent({this.status});

  @override
  List<Object?> get props => [status];
}

/// Load pending bookings event (owner)
class LoadPendingBookingsEvent extends BookingEvent {
  const LoadPendingBookingsEvent();
}

/// Load booking by ID event
class LoadBookingByIdEvent extends BookingEvent {
  final String bookingId;

  const LoadBookingByIdEvent(this.bookingId);

  @override
  List<Object> get props => [bookingId];
}

/// Cancel booking event
class CancelBookingEvent extends BookingEvent {
  final String bookingId;
  final String reason;

  const CancelBookingEvent({required this.bookingId, required this.reason});

  @override
  List<Object> get props => [bookingId, reason];
}

/// Approve booking event (owner)
class ApproveBookingEvent extends BookingEvent {
  final String bookingId;
  final String? message;

  const ApproveBookingEvent({required this.bookingId, this.message});

  @override
  List<Object?> get props => [bookingId, message];
}

/// Reject booking event (owner)
class RejectBookingEvent extends BookingEvent {
  final String bookingId;
  final String reason;

  const RejectBookingEvent({required this.bookingId, required this.reason});

  @override
  List<Object> get props => [bookingId, reason];
}

/// Reset booking state event
class ResetBookingStateEvent extends BookingEvent {
  const ResetBookingStateEvent();
}
