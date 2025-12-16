import 'package:equatable/equatable.dart';
import '../../domain/entities/booking.dart';

/// Base class for booking states
abstract class BookingState extends Equatable {
  const BookingState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class BookingInitial extends BookingState {
  const BookingInitial();
}

/// Loading state
class BookingLoading extends BookingState {
  const BookingLoading();
}

/// Bookings loaded state (list)
class BookingsLoaded extends BookingState {
  final List<BookingEntity> bookings;

  const BookingsLoaded(this.bookings);

  @override
  List<Object> get props => [bookings];
}

/// Single booking loaded state
class BookingLoaded extends BookingState {
  final BookingEntity booking;

  const BookingLoaded(this.booking);

  @override
  List<Object> get props => [booking];
}

/// Booking created successfully
class BookingCreated extends BookingState {
  final BookingEntity booking;

  const BookingCreated(this.booking);

  @override
  List<Object> get props => [booking];
}

/// Booking updated successfully
class BookingUpdated extends BookingState {
  final BookingEntity booking;
  final String message;

  const BookingUpdated(this.booking, {this.message = 'Booking updated'});

  @override
  List<Object> get props => [booking, message];
}

/// Booking action success (approve, reject, cancel)
class BookingActionSuccess extends BookingState {
  final BookingEntity booking;
  final String message;

  const BookingActionSuccess(this.booking, this.message);

  @override
  List<Object> get props => [booking, message];
}

/// Failure state
class BookingFailure extends BookingState {
  final String message;

  const BookingFailure(this.message);

  @override
  List<Object> get props => [message];
}
