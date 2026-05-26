import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/claim_summary.dart';
import '../entities/incident_report.dart';
import '../repositories/incident_repository.dart';

class GetBookingIncidentsParams {
  final String bookingId;

  const GetBookingIncidentsParams(this.bookingId);
}

class GetBookingIncidentsUseCase
    implements UseCase<List<IncidentReportEntity>, GetBookingIncidentsParams> {
  final IncidentRepository repository;

  GetBookingIncidentsUseCase(this.repository);

  @override
  Future<Either<Failure, List<IncidentReportEntity>>> call(
    GetBookingIncidentsParams params,
  ) {
    return repository.getBookingIncidents(params.bookingId);
  }
}

class GetBookingClaimSummaryParams {
  final String bookingId;

  const GetBookingClaimSummaryParams(this.bookingId);
}

class GetBookingClaimSummaryUseCase
    implements
        UseCase<BookingClaimSummaryEntity, GetBookingClaimSummaryParams> {
  final IncidentRepository repository;

  GetBookingClaimSummaryUseCase(this.repository);

  @override
  Future<Either<Failure, BookingClaimSummaryEntity>> call(
    GetBookingClaimSummaryParams params,
  ) {
    return repository.getBookingClaimSummary(params.bookingId);
  }
}

class CreateIncidentReportParams {
  final String bookingId;
  final String? tripId;
  final String? postTripChargeId;
  final IncidentCategory category;
  final IncidentSeverity severity;
  final String description;
  final List<String>? evidenceUrls;
  final List<IncidentEvidenceUpload>? evidenceUploads;
  final List<String>? handoverPhotoIds;

  const CreateIncidentReportParams({
    required this.bookingId,
    this.tripId,
    this.postTripChargeId,
    required this.category,
    required this.severity,
    required this.description,
    this.evidenceUrls,
    this.evidenceUploads,
    this.handoverPhotoIds,
  });
}

class CreateIncidentReportUseCase
    implements UseCase<IncidentReportEntity, CreateIncidentReportParams> {
  final IncidentRepository repository;

  CreateIncidentReportUseCase(this.repository);

  @override
  Future<Either<Failure, IncidentReportEntity>> call(
    CreateIncidentReportParams params,
  ) {
    return repository.createIncidentReport(
      bookingId: params.bookingId,
      tripId: params.tripId,
      postTripChargeId: params.postTripChargeId,
      category: params.category,
      severity: params.severity,
      description: params.description,
      evidenceUrls: params.evidenceUrls,
      evidenceUploads: params.evidenceUploads,
      handoverPhotoIds: params.handoverPhotoIds,
    );
  }
}
