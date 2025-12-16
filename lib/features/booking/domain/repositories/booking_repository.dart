import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/booking.dart';

/// Abstract repository interface for bookings
/// Following Dependency Inversion Principle - Domain layer defines the contract
abstract class BookingRepository {
  /// Create a new booking (renter)
  Future<Either<Failure, BookingEntity>> createBooking({
    required String vehicleId,
    required DateTime startTime,
    required DateTime endTime,
    String? notes,
  });

  /// Get renter bookings
  Future<Either<Failure, List<BookingEntity>>> getRenterBookings({
    BookingStatus? status,
  });

  /// Get upcoming bookings
  Future<Either<Failure, List<BookingEntity>>> getUpcomingBookings();

  /// Get booking history
  Future<Either<Failure, List<BookingEntity>>> getBookingHistory();

  /// Get booking by ID
  Future<Either<Failure, BookingEntity>> getBookingById(String bookingId);

  /// Cancel booking (renter)
  Future<Either<Failure, BookingEntity>> cancelBooking(
    String bookingId,
    String reason,
  );

  /// Get owner bookings
  Future<Either<Failure, List<BookingEntity>>> getOwnerBookings({
    BookingStatus? status,
  });

  /// Get pending bookings (owner)
  Future<Either<Failure, List<BookingEntity>>> getPendingBookings();

  /// Approve booking (owner)
  Future<Either<Failure, BookingEntity>> approveBooking(
    String bookingId, {
    String? message,
  });

  /// Reject booking (owner)
  Future<Either<Failure, BookingEntity>> rejectBooking(
    String bookingId,
    String reason,
  );
}
