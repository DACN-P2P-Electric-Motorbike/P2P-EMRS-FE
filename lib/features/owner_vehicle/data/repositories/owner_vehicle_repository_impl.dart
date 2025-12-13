import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/vehicle_entity.dart';
import '../../domain/repositories/owner_vehicle_repository.dart';
import '../datasources/owner_vehicle_remote_data_source.dart';
import '../models/create_vehicle_params.dart';
import '../models/update_vehicle_params.dart';

/// Implementation of OwnerVehicleRepository
class OwnerVehicleRepositoryImpl implements OwnerVehicleRepository {
  final OwnerVehicleRemoteDataSource _remoteDataSource;

  OwnerVehicleRepositoryImpl({
    required OwnerVehicleRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, List<VehicleEntity>>> getMyVehicles() async {
    try {
      final vehicles = await _remoteDataSource.getMyVehicles();
      return Right(vehicles.map((v) => v.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on ConnectionException {
      return const Left(ConnectionFailure());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, VehicleEntity>> registerVehicle(
      CreateVehicleParams params) async {
    try {
      final vehicle = await _remoteDataSource.registerVehicle(params);
      return Right(vehicle.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on ConnectionException {
      return const Left(ConnectionFailure());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, VehicleEntity>> getVehicleById(String id) async {
    try {
      final vehicle = await _remoteDataSource.getVehicleById(id);
      return Right(vehicle.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on ConnectionException {
      return const Left(ConnectionFailure());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, VehicleEntity>> updateVehicle(
      String id, UpdateVehicleParams params) async {
    try {
      final vehicle = await _remoteDataSource.updateVehicle(id, params);
      return Right(vehicle.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on ConnectionException {
      return const Left(ConnectionFailure());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteVehicle(String id) async {
    try {
      await _remoteDataSource.deleteVehicle(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on ConnectionException {
      return const Left(ConnectionFailure());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}

