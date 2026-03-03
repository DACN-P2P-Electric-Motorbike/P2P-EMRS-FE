import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/trip_entity.dart';
import '../../domain/repositories/trip_repository.dart';
import '../datasources/trip_remote_datasource.dart';

class TripRepositoryImpl implements TripRepository {
  final TripRemoteDataSource _remoteDataSource;

  TripRepositoryImpl({required TripRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, TripEntity>> startTrip({
    required String bookingId,
    double? startLatitude,
    double? startLongitude,
    String? startAddress,
    double? startBattery,
  }) async {
    try {
      final trip = await _remoteDataSource.startTrip(
        bookingId: bookingId,
        startLatitude: startLatitude,
        startLongitude: startLongitude,
        startAddress: startAddress,
        startBattery: startBattery,
      );
      return Right(trip.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on ConnectionException {
      return const Left(ConnectionFailure());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, TripEntity>> endTrip({
    required String tripId,
    double? endLatitude,
    double? endLongitude,
    String? endAddress,
    double? endBattery,
    bool hasIssues = false,
    String? issueDescription,
  }) async {
    try {
      final trip = await _remoteDataSource.endTrip(
        tripId: tripId,
        endLatitude: endLatitude,
        endLongitude: endLongitude,
        endAddress: endAddress,
        endBattery: endBattery,
        hasIssues: hasIssues,
        issueDescription: issueDescription,
      );
      return Right(trip.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on ConnectionException {
      return const Left(ConnectionFailure());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, TripEntity?>> getActiveTrip() async {
    try {
      final trip = await _remoteDataSource.getActiveTrip();
      return Right(trip?.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on ConnectionException {
      return const Left(ConnectionFailure());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<TripEntity>>> getTripHistory() async {
    try {
      final trips = await _remoteDataSource.getTripHistory();
      return Right(trips.map((t) => t.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on ConnectionException {
      return const Left(ConnectionFailure());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, TripEntity>> getTripById(String tripId) async {
    try {
      final trip = await _remoteDataSource.getTripById(tripId);
      return Right(trip.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on ConnectionException {
      return const Left(ConnectionFailure());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
