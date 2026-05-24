import 'package:equatable/equatable.dart';

enum IncidentCategory {
  accident,
  damage,
  theft,
  mechanicalIssue,
  noShow,
  vehicleMismatch,
  lateReturn,
  other;

  static IncidentCategory fromString(String value) {
    switch (value.toUpperCase()) {
      case 'ACCIDENT':
        return IncidentCategory.accident;
      case 'DAMAGE':
        return IncidentCategory.damage;
      case 'THEFT':
        return IncidentCategory.theft;
      case 'NO_SHOW':
        return IncidentCategory.noShow;
      case 'VEHICLE_MISMATCH':
        return IncidentCategory.vehicleMismatch;
      case 'LATE_RETURN':
        return IncidentCategory.lateReturn;
      case 'MECHANICAL_ISSUE':
        return IncidentCategory.mechanicalIssue;
      case 'OTHER':
      default:
        return IncidentCategory.other;
    }
  }

  String get apiValue {
    switch (this) {
      case IncidentCategory.accident:
        return 'ACCIDENT';
      case IncidentCategory.damage:
        return 'DAMAGE';
      case IncidentCategory.theft:
        return 'THEFT';
      case IncidentCategory.mechanicalIssue:
        return 'MECHANICAL_ISSUE';
      case IncidentCategory.noShow:
        return 'NO_SHOW';
      case IncidentCategory.vehicleMismatch:
        return 'VEHICLE_MISMATCH';
      case IncidentCategory.lateReturn:
        return 'LATE_RETURN';
      case IncidentCategory.other:
        return 'OTHER';
    }
  }

  String get displayText {
    switch (this) {
      case IncidentCategory.accident:
        return 'Tai nạn';
      case IncidentCategory.damage:
        return 'Hư hỏng';
      case IncidentCategory.theft:
        return 'Mất cắp';
      case IncidentCategory.mechanicalIssue:
        return 'Sự cố kỹ thuật';
      case IncidentCategory.noShow:
        return 'Không bàn giao';
      case IncidentCategory.vehicleMismatch:
        return 'Xe không đúng mô tả';
      case IncidentCategory.lateReturn:
        return 'Trả xe trễ';
      case IncidentCategory.other:
        return 'Khác';
    }
  }

  bool get requiresEvidence {
    return this == IncidentCategory.accident ||
        this == IncidentCategory.damage ||
        this == IncidentCategory.theft ||
        this == IncidentCategory.vehicleMismatch;
  }
}

enum IncidentSeverity {
  low,
  medium,
  high,
  critical;

  static IncidentSeverity fromString(String value) {
    switch (value.toUpperCase()) {
      case 'LOW':
        return IncidentSeverity.low;
      case 'HIGH':
        return IncidentSeverity.high;
      case 'CRITICAL':
        return IncidentSeverity.critical;
      case 'MEDIUM':
      default:
        return IncidentSeverity.medium;
    }
  }

  String get apiValue {
    switch (this) {
      case IncidentSeverity.low:
        return 'LOW';
      case IncidentSeverity.medium:
        return 'MEDIUM';
      case IncidentSeverity.high:
        return 'HIGH';
      case IncidentSeverity.critical:
        return 'CRITICAL';
    }
  }

  String get displayText {
    switch (this) {
      case IncidentSeverity.low:
        return 'Thấp';
      case IncidentSeverity.medium:
        return 'Trung bình';
      case IncidentSeverity.high:
        return 'Cao';
      case IncidentSeverity.critical:
        return 'Nghiêm trọng';
    }
  }
}

enum IncidentStatus {
  open,
  underReview,
  resolved,
  rejected;

  static IncidentStatus fromString(String value) {
    switch (value.toUpperCase()) {
      case 'UNDER_REVIEW':
        return IncidentStatus.underReview;
      case 'RESOLVED':
        return IncidentStatus.resolved;
      case 'REJECTED':
        return IncidentStatus.rejected;
      case 'OPEN':
      default:
        return IncidentStatus.open;
    }
  }

  String get displayText {
    switch (this) {
      case IncidentStatus.open:
        return 'Đã gửi';
      case IncidentStatus.underReview:
        return 'Đang xem xét';
      case IncidentStatus.resolved:
        return 'Đã xử lý';
      case IncidentStatus.rejected:
        return 'Đã từ chối';
    }
  }
}

class IncidentReportEntity extends Equatable {
  final String id;
  final String bookingId;
  final String? tripId;
  final String? postTripChargeId;
  final String reporterId;
  final IncidentCategory category;
  final IncidentSeverity severity;
  final IncidentStatus status;
  final String description;
  final List<String> evidenceUrls;
  final int handoverPhotoCount;
  final bool photoRequired;
  final bool evidenceSatisfied;
  final String? adminNotes;
  final DateTime? reviewedAt;
  final DateTime? resolvedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const IncidentReportEntity({
    required this.id,
    required this.bookingId,
    this.tripId,
    this.postTripChargeId,
    required this.reporterId,
    required this.category,
    required this.severity,
    required this.status,
    required this.description,
    this.evidenceUrls = const [],
    this.handoverPhotoCount = 0,
    this.photoRequired = false,
    this.evidenceSatisfied = true,
    this.adminNotes,
    this.reviewedAt,
    this.resolvedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isOpen =>
      status == IncidentStatus.open || status == IncidentStatus.underReview;

  @override
  List<Object?> get props => [
    id,
    bookingId,
    tripId,
    postTripChargeId,
    reporterId,
    category,
    severity,
    status,
    description,
    evidenceUrls,
    handoverPhotoCount,
    photoRequired,
    evidenceSatisfied,
    adminNotes,
    reviewedAt,
    resolvedAt,
    createdAt,
    updatedAt,
  ];
}
