import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/handover.dart';
import '../../domain/repositories/handover_repository.dart';
import '../datasources/handover_remote_datasource.dart';

class HandoverRepositoryImpl implements HandoverRepository {
  final HandoverRemoteDataSource _remoteDataSource;

  HandoverRepositoryImpl({required HandoverRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, VehicleHandover>> createCheckIn({
    required String bookingId,
    required List<HandoverPhotoInput> photos,
    double? odometerReading,
    int? batteryLevel,
    int? fuelLevel,
    double? latitude,
    double? longitude,
    String? notes,
  }) {
    return _guard(
      () => _remoteDataSource.createCheckIn(
        bookingId: bookingId,
        photos: photos,
        odometerReading: odometerReading,
        batteryLevel: batteryLevel,
        fuelLevel: fuelLevel,
        latitude: latitude,
        longitude: longitude,
        notes: notes,
      ),
      (model) => model.toEntity(),
    );
  }

  @override
  Future<Either<Failure, VehicleHandover>> createCheckOut({
    required String bookingId,
    required List<HandoverPhotoInput> photos,
    double? odometerReading,
    int? batteryLevel,
    int? fuelLevel,
    double? latitude,
    double? longitude,
    String? notes,
  }) {
    return _guard(
      () => _remoteDataSource.createCheckOut(
        bookingId: bookingId,
        photos: photos,
        odometerReading: odometerReading,
        batteryLevel: batteryLevel,
        fuelLevel: fuelLevel,
        latitude: latitude,
        longitude: longitude,
        notes: notes,
      ),
      (model) => model.toEntity(),
    );
  }

  @override
  Future<Either<Failure, HandoverSummary>> getByBooking(String bookingId) {
    return _guard(
      () => _remoteDataSource.getByBooking(bookingId),
      (model) => model.toEntity(),
    );
  }

  @override
  Future<Either<Failure, VehicleHandover>> confirm(String handoverId) {
    return _guard(
      () => _remoteDataSource.confirm(handoverId),
      (model) => model.toEntity(),
    );
  }

  Future<Either<Failure, TEntity>> _guard<TModel, TEntity>(
    Future<TModel> Function() request,
    TEntity Function(TModel model) map,
  ) async {
    try {
      final result = await request();
      return Right(map(result));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on ConnectionException {
      return const Left(ConnectionFailure());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
