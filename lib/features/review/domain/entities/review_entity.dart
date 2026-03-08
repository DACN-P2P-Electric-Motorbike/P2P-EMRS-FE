import 'package:equatable/equatable.dart';

class ReviewEntity extends Equatable {
  final String id;
  final String userId;
  final String vehicleId;
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
  ];
}
