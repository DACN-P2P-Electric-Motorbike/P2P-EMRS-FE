import 'package:equatable/equatable.dart';

class ReviewEntity extends Equatable {
  final String id;
  final String userId;
  final String vehicleId;
  final String? tripId;
  final String? bookingId;
  final int rating;
  final String? comment;
  final String? userName;
  final String? userAvatarUrl;
  final String? vehicleName;
  final String? vehicleBrand;
  final String? vehicleImage;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ReviewEntity({
    required this.id,
    required this.userId,
    required this.vehicleId,
    this.tripId,
    this.bookingId,
    required this.rating,
    this.comment,
    this.userName,
    this.userAvatarUrl,
    this.vehicleName,
    this.vehicleBrand,
    this.vehicleImage,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    vehicleId,
    tripId,
    bookingId,
    rating,
    comment,
    userName,
    userAvatarUrl,
    vehicleName,
    vehicleBrand,
    vehicleImage,
    createdAt,
    updatedAt,
  ];
}

class TrustScoreBreakdown extends Equatable {
  final int trustScore;
  final int reviewsGiven;
  final int reviewsGivenBonus;
  final double? avgRatingReceived;
  final int totalReviewsReceived;
  final int cancelledBookings;
  final int cancellationPenalty;
  final int rejectedBookings;
  final int rejectionPenalty;
  final int completedTrips;
  final int tripsWithIssues;
  final int violationPenalty;
  final List<TrustScoreEvent> recentEvents;
  final List<TrustScoreWarning> activeWarnings;

  const TrustScoreBreakdown({
    required this.trustScore,
    required this.reviewsGiven,
    required this.reviewsGivenBonus,
    this.avgRatingReceived,
    required this.totalReviewsReceived,
    required this.cancelledBookings,
    required this.cancellationPenalty,
    required this.rejectedBookings,
    required this.rejectionPenalty,
    required this.completedTrips,
    required this.tripsWithIssues,
    required this.violationPenalty,
    this.recentEvents = const [],
    this.activeWarnings = const [],
  });

  @override
  List<Object?> get props => [
    trustScore,
    reviewsGiven,
    reviewsGivenBonus,
    avgRatingReceived,
    totalReviewsReceived,
    cancelledBookings,
    cancellationPenalty,
    rejectedBookings,
    rejectionPenalty,
    completedTrips,
    tripsWithIssues,
    violationPenalty,
    recentEvents,
    activeWarnings,
  ];
}

/// Mirrors the `TrustScoreEventType` enum on the backend so the FE can render
/// human-friendly icons and labels for each event/warning.
enum TrustScoreEventType {
  tripCompletedOnTime,
  goodReviewReceived,
  reviewSubmitted,
  kycVerified,
  transactionMilestone,
  badReviewReceived,
  bookingCancelledByRenter,
  bookingRejectedByOwner,
  lateReturn,
  confirmedReport,
  seriousViolation,
  manualAdjustment,
  recalculated,
  warning,
  unknown;

  static TrustScoreEventType parse(String? raw) {
    switch ((raw ?? '').toUpperCase()) {
      case 'TRIP_COMPLETED_ON_TIME':
        return TrustScoreEventType.tripCompletedOnTime;
      case 'GOOD_REVIEW_RECEIVED':
        return TrustScoreEventType.goodReviewReceived;
      case 'REVIEW_SUBMITTED':
        return TrustScoreEventType.reviewSubmitted;
      case 'KYC_VERIFIED':
        return TrustScoreEventType.kycVerified;
      case 'TRANSACTION_MILESTONE':
        return TrustScoreEventType.transactionMilestone;
      case 'BAD_REVIEW_RECEIVED':
        return TrustScoreEventType.badReviewReceived;
      case 'BOOKING_CANCELLED_BY_RENTER':
        return TrustScoreEventType.bookingCancelledByRenter;
      case 'BOOKING_REJECTED_BY_OWNER':
        return TrustScoreEventType.bookingRejectedByOwner;
      case 'LATE_RETURN':
        return TrustScoreEventType.lateReturn;
      case 'CONFIRMED_REPORT':
        return TrustScoreEventType.confirmedReport;
      case 'SERIOUS_VIOLATION':
        return TrustScoreEventType.seriousViolation;
      case 'MANUAL_ADJUSTMENT':
        return TrustScoreEventType.manualAdjustment;
      case 'RECALCULATED':
        return TrustScoreEventType.recalculated;
      case 'WARNING':
        return TrustScoreEventType.warning;
      default:
        return TrustScoreEventType.unknown;
    }
  }
}

class TrustScoreEvent extends Equatable {
  final String id;
  final TrustScoreEventType type;
  final double delta;
  final double scoreBefore;
  final double scoreAfter;
  final String? reason;
  final DateTime createdAt;

  const TrustScoreEvent({
    required this.id,
    required this.type,
    required this.delta,
    required this.scoreBefore,
    required this.scoreAfter,
    required this.createdAt,
    this.reason,
  });

  bool get isPositive => delta > 0;
  bool get isNegative => delta < 0;
  bool get isWarning => type == TrustScoreEventType.warning;

  @override
  List<Object?> get props => [
    id,
    type,
    delta,
    scoreBefore,
    scoreAfter,
    reason,
    createdAt,
  ];
}

class TrustScoreWarning extends Equatable {
  final String id;
  final TrustScoreEventType type;
  final String? reason;
  final DateTime createdAt;
  final DateTime expiresAt;
  final DateTime? penalizedAt;

  const TrustScoreWarning({
    required this.id,
    required this.type,
    required this.createdAt,
    required this.expiresAt,
    this.reason,
    this.penalizedAt,
  });

  /// True while the 30-day warning window is still active.
  bool get isActive => penalizedAt == null && expiresAt.isAfter(DateTime.now());

  Duration? get remaining {
    if (!isActive) return null;
    return expiresAt.difference(DateTime.now());
  }

  @override
  List<Object?> get props => [
    id,
    type,
    reason,
    createdAt,
    expiresAt,
    penalizedAt,
  ];
}
