import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/incident_report.dart';

abstract class IncidentRepository {
  Future<Either<Failure, List<IncidentReportEntity>>> getBookingIncidents(
    String bookingId,
  );

  Future<Either<Failure, IncidentReportEntity>> createIncidentReport({
    required String bookingId,
    String? tripId,
    String? postTripChargeId,
    required IncidentCategory category,
    required IncidentSeverity severity,
    required String description,
    List<String>? evidenceUrls,
    List<String>? handoverPhotoIds,
  });
}
