import '../../domain/entities/incident_report.dart';

class IncidentReportModel {
  final String id;
  final String bookingId;
  final String? tripId;
  final String? postTripChargeId;
  final String reporterId;
  final String category;
  final String severity;
  final String status;
  final String description;
  final List<String> evidenceUrls;
  final int handoverPhotoCount;
  final int jointlyConfirmedHandoverPhotoCount;
  final bool photoRequired;
  final bool evidenceSatisfied;
  final String? adminNotes;
  final DateTime? reviewedAt;
  final DateTime? resolvedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const IncidentReportModel({
    required this.id,
    required this.bookingId,
    this.tripId,
    this.postTripChargeId,
    required this.reporterId,
    required this.category,
    required this.severity,
    required this.status,
    required this.description,
    required this.evidenceUrls,
    required this.handoverPhotoCount,
    this.jointlyConfirmedHandoverPhotoCount = 0,
    required this.photoRequired,
    required this.evidenceSatisfied,
    this.adminNotes,
    this.reviewedAt,
    this.resolvedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory IncidentReportModel.fromJson(Map<String, dynamic> json) {
    final evidence = _asMap(json['evidence']);
    final requiredEvidence = _asMap(json['requiredEvidence']);
    final handoverPhotos = evidence['handoverPhotos'];
    final handoverPhotoList = handoverPhotos is List
        ? handoverPhotos
        : const <dynamic>[];

    return IncidentReportModel(
      id: json['id'] as String? ?? '',
      bookingId: json['bookingId'] as String? ?? '',
      tripId: json['tripId'] as String?,
      postTripChargeId: json['postTripChargeId'] as String?,
      reporterId: json['reporterId'] as String? ?? '',
      category: json['category'] as String? ?? 'OTHER',
      severity: json['severity'] as String? ?? 'MEDIUM',
      status: json['status'] as String? ?? 'OPEN',
      description: json['description'] as String? ?? '',
      evidenceUrls: _stringList(evidence['evidenceUrls']),
      handoverPhotoCount: handoverPhotoList.length,
      jointlyConfirmedHandoverPhotoCount: handoverPhotoList
          .where(
            (photo) =>
                photo is Map &&
                Map<String, dynamic>.from(photo)['jointlyConfirmed'] == true,
          )
          .length,
      photoRequired: requiredEvidence['photoRequired'] == true,
      evidenceSatisfied: requiredEvidence['satisfied'] != false,
      adminNotes: json['adminNotes'] as String?,
      reviewedAt: _parseDate(json['reviewedAt']),
      resolvedAt: _parseDate(json['resolvedAt']),
      createdAt: _parseRequiredDate(json['createdAt']),
      updatedAt: _parseRequiredDate(json['updatedAt']),
    );
  }

  IncidentReportEntity toEntity() {
    return IncidentReportEntity(
      id: id,
      bookingId: bookingId,
      tripId: tripId,
      postTripChargeId: postTripChargeId,
      reporterId: reporterId,
      category: IncidentCategory.fromString(category),
      severity: IncidentSeverity.fromString(severity),
      status: IncidentStatus.fromString(status),
      description: description,
      evidenceUrls: evidenceUrls,
      handoverPhotoCount: handoverPhotoCount,
      jointlyConfirmedHandoverPhotoCount: jointlyConfirmedHandoverPhotoCount,
      photoRequired: photoRequired,
      evidenceSatisfied: evidenceSatisfied,
      adminNotes: adminNotes,
      reviewedAt: reviewedAt,
      resolvedAt: resolvedAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return const {};
}

List<String> _stringList(dynamic value) {
  if (value is! List) return const [];
  return value
      .whereType<String>()
      .map((item) => item.trim())
      .where((item) => item.isNotEmpty)
      .toList();
}

DateTime? _parseDate(dynamic value) {
  if (value is! String || value.isEmpty) return null;
  return DateTime.tryParse(value);
}

DateTime _parseRequiredDate(dynamic value) {
  return _parseDate(value) ?? DateTime.fromMillisecondsSinceEpoch(0);
}
