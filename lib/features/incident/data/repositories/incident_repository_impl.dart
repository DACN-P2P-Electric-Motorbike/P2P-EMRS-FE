import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/claim_summary.dart';
import '../../domain/entities/incident_report.dart';
import '../../domain/repositories/incident_repository.dart';
import '../datasources/incident_remote_datasource.dart';

class IncidentRepositoryImpl implements IncidentRepository {
  final IncidentRemoteDataSource _remoteDataSource;

  IncidentRepositoryImpl({required IncidentRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, List<IncidentReportEntity>>> getBookingIncidents(
    String bookingId,
  ) async {
    try {
      final reports = await _remoteDataSource.getBookingIncidents(bookingId);
      return Right(reports.map((report) => report.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on ConnectionException {
      return const Left(ConnectionFailure());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, BookingClaimSummaryEntity>> getBookingClaimSummary(
    String bookingId,
  ) async {
    try {
      final summary = await _remoteDataSource.getBookingClaimSummary(bookingId);
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
  Future<Either<Failure, IncidentReportEntity>> createIncidentReport({
    required String bookingId,
    String? tripId,
    String? postTripChargeId,
    required IncidentCategory category,
    required IncidentSeverity severity,
    required String description,
    List<String>? evidenceUrls,
    List<IncidentEvidenceUpload>? evidenceUploads,
    List<String>? handoverPhotoIds,
  }) async {
    try {
      final report = await _remoteDataSource.createIncidentReport(
        bookingId: bookingId,
        tripId: tripId,
        postTripChargeId: postTripChargeId,
        category: category.apiValue,
        severity: severity.apiValue,
        description: description,
        evidenceUrls: evidenceUrls,
        evidenceUploads: evidenceUploads,
        handoverPhotoIds: handoverPhotoIds,
      );
      return Right(report.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on ConnectionException {
      return const Left(ConnectionFailure());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
