import 'package:dartz/dartz.dart';
import 'package:fe_capstone_project/features/vehicle/domain/entities/vehicle_entity.dart';
import '../../../../../core/error/exceptions.dart';
import '../../../../../core/error/failures.dart';
import '../../domain/repositories/vehicle_repository.dart';
import '../datasources/vehicle_remote_datasource.dart';

class VehicleRepositoryImpl implements VehicleRepository {
  final VehicleRemoteDataSource _remoteDataSource;

  VehicleRepositoryImpl({required VehicleRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, List<VehicleEntity>>> getAvailableVehicles() async {
    try {
      final vehicles = await _remoteDataSource.getAvailableVehicles();
      return Right(vehicles.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException {
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
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException {
      return const Left(ConnectionFailure());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<VehicleEntity>>> searchVehicles({
    String? brand,
    String? model,
    double? maxPrice,
    double? latitude,
    double? longitude,
    double? radius,
  }) async {
    try {
      final vehicles = await _remoteDataSource.searchVehicles(
        brand: brand,
        model: model,
        maxPrice: maxPrice,
        latitude: latitude,
        longitude: longitude,
        radius: radius,
      );
      return Right(vehicles.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException {
      return const Left(ConnectionFailure());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<VehicleEntity>>> getNearbyVehicles({
    required double latitude,
    required double longitude,
    double radius = 5.0,
  }) async {
    try {
      final vehicles = await _remoteDataSource.getNearbyVehicles(
        latitude: latitude,
        longitude: longitude,
        radius: radius,
      );
      return Right(vehicles.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException {
      return const Left(ConnectionFailure());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveVehicle(String vehicleId) async {
    try {
      // TODO: Implement local storage or API call for saved vehicles
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removeSavedVehicle(String vehicleId) async {
    try {
      // TODO: Implement local storage or API call for saved vehicles
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<VehicleEntity>>> getSavedVehicles() async {
    try {
      // TODO: Implement local storage or API call for saved vehicles
      return const Right([]);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
