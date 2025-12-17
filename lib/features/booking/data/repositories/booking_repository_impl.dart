import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/booking.dart';
import '../../domain/repositories/booking_repository.dart';
import '../datasources/booking_remote_datasource.dart';

/// Implementation of BookingRepository
class BookingRepositoryImpl implements BookingRepository {
  final BookingRemoteDataSource _remoteDataSource;

  BookingRepositoryImpl({required BookingRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, BookingEntity>> createBooking({
    required String vehicleId,
    required DateTime startTime,
    required DateTime endTime,
    String? notes,
  }) async {
    try {
      final model = await _remoteDataSource.createBooking(
        vehicleId: vehicleId,
        startTime: startTime,
        endTime: endTime,
        notes: notes,
      );
      return Right(model.toEntity());
    } on NetworkException {
      return const Left(ConnectionFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<BookingEntity>>> getRenterBookings({
    BookingStatus? status,
  }) async {
    try {
      final models = await _remoteDataSource.getRenterBookings(
        status: status?.name,
      );
      return Right(models.map((m) => m.toEntity()).toList());
    } on NetworkException {
      return const Left(ConnectionFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<BookingEntity>>> getUpcomingBookings() async {
    try {
      final models = await _remoteDataSource.getUpcomingBookings();
      return Right(models.map((m) => m.toEntity()).toList());
    } on NetworkException {
      return const Left(ConnectionFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<BookingEntity>>> getBookingHistory() async {
    try {
      final models = await _remoteDataSource.getBookingHistory();
      return Right(models.map((m) => m.toEntity()).toList());
    } on NetworkException {
      return const Left(ConnectionFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, BookingEntity>> getBookingById(
    String bookingId,
  ) async {
    try {
      final model = await _remoteDataSource.getBookingById(bookingId);
      return Right(model.toEntity());
    } on NetworkException {
      return const Left(ConnectionFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, BookingEntity>> cancelBooking(
    String bookingId,
    String reason,
  ) async {
    try {
      final model = await _remoteDataSource.cancelBooking(bookingId, reason);
      return Right(model.toEntity());
    } on NetworkException {
      return const Left(ConnectionFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<BookingEntity>>> getOwnerBookings({
    BookingStatus? status,
  }) async {
    try {
      final models = await _remoteDataSource.getOwnerBookings(
        status: status?.name,
      );
      return Right(models.map((m) => m.toEntity()).toList());
    } on NetworkException {
      return const Left(ConnectionFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<BookingEntity>>> getPendingBookings() async {
    try {
      final models = await _remoteDataSource.getPendingBookings();
      return Right(models.map((m) => m.toEntity()).toList());
    } on NetworkException {
      return const Left(ConnectionFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, BookingEntity>> approveBooking(
    String bookingId, {
    String? message,
  }) async {
    try {
      final model = await _remoteDataSource.approveBooking(
        bookingId,
        message: message,
      );
      return Right(model.toEntity());
    } on NetworkException {
      return const Left(ConnectionFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, BookingEntity>> rejectBooking(
    String bookingId,
    String reason,
  ) async {
    try {
      final model = await _remoteDataSource.rejectBooking(bookingId, reason);
      return Right(model.toEntity());
    } on NetworkException {
      return const Left(ConnectionFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
