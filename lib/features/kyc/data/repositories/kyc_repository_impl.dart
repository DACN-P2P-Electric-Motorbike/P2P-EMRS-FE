import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/kyc_verification.dart';
import '../../domain/repositories/kyc_repository.dart';
import '../datasources/kyc_remote_datasource.dart';

class KycRepositoryImpl implements KycRepository {
  final KycRemoteDataSource _remoteDataSource;

  KycRepositoryImpl({required KycRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, KycVerification>> getStatus() async {
    try {
      final model = await _remoteDataSource.getStatus();
      return Right(model);
    } on NetworkException {
      return const Left(ConnectionFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, KycVerification>> submit({
    required String selfieUrl,
    required String idCardFrontUrl,
    required String idCardBackUrl,
  }) async {
    try {
      final model = await _remoteDataSource.submit(
        selfieUrl: selfieUrl,
        idCardFrontUrl: idCardFrontUrl,
        idCardBackUrl: idCardBackUrl,
      );
      return Right(model);
    } on NetworkException {
      return const Left(ConnectionFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
