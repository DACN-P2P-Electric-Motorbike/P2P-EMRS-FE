import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/financial_summary.dart';
import '../../domain/repositories/financial_repository.dart';
import '../datasources/financial_remote_datasource.dart';

class FinancialRepositoryImpl implements FinancialRepository {
  final FinancialRemoteDataSource _remoteDataSource;

  FinancialRepositoryImpl({required FinancialRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, FinancialSummaryEntity>> getBookingFinancialSummary(
    String bookingId,
  ) async {
    try {
      final summary = await _remoteDataSource.getBookingFinancialSummary(
        bookingId,
      );
      return Right(summary.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on ConnectionException {
      return const Left(ConnectionFailure());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, FinancialSummaryEntity>> createManualPostTripCharge({
    required String bookingId,
    required PostTripChargeType type,
    required double amount,
    required String description,
    double? quantity,
    double? unitPrice,
    List<String>? evidenceUrls,
  }) async {
    try {
      final summary = await _remoteDataSource.createManualPostTripCharge(
        bookingId: bookingId,
        type: _chargeTypeToApi(type),
        amount: amount,
        description: description,
        quantity: quantity,
        unitPrice: unitPrice,
        evidenceUrls: evidenceUrls,
      );
      return Right(summary.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on ConnectionException {
      return const Left(ConnectionFailure());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  String _chargeTypeToApi(PostTripChargeType type) {
    switch (type) {
      case PostTripChargeType.lateReturn:
        return 'LATE_RETURN';
      case PostTripChargeType.excessDistance:
        return 'EXCESS_DISTANCE';
      case PostTripChargeType.lowBattery:
        return 'LOW_BATTERY';
      case PostTripChargeType.cleaning:
        return 'CLEANING';
      case PostTripChargeType.damage:
        return 'DAMAGE';
      case PostTripChargeType.roadsideAssistance:
        return 'ROADSIDE_ASSISTANCE';
      case PostTripChargeType.other:
        return 'OTHER';
    }
  }
}
