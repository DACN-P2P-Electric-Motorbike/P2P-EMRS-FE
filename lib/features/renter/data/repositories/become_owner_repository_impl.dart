import 'package:dartz/dartz.dart';
import 'package:fe_capstone_project/features/owner_vehicle/data/models/create_vehicle_params.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/become_owner_repository.dart';
import '../datasources/become_owner_remote_datasource.dart';
import '../models/become_owner_response_model.dart';

class BecomeOwnerRepositoryImpl implements BecomeOwnerRepository {
  final BecomeOwnerRemoteDataSource _remoteDataSource;

  BecomeOwnerRepositoryImpl({
    required BecomeOwnerRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, BecomeOwnerResponseDto>> becomeOwner(
    CreateVehicleParams vehicleData,
  ) async {
    try {
      final response = await _remoteDataSource.becomeOwner(vehicleData);
      return Right(response);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException {
      return const Left(ConnectionFailure());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
