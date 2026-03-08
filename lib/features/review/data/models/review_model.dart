import '../../domain/entities/review_entity.dart';

class ReviewModel extends ReviewEntity {
  const ReviewModel({
    required super.id,
    required super.userId,
    required super.vehicleId,
    required super.rating,
    super.comment,
    super.userName,
    super.userAvatarUrl,
    super.vehicleName,
    super.vehicleBrand,
    super.vehicleImage,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>?;
    final vehicle = json['vehicle'] as Map<String, dynamic>?;
    final images = vehicle?['images'] as List<dynamic>?;
    return ReviewModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      vehicleId: json['vehicleId'] as String,
      rating: json['rating'] as int,
      comment: json['comment'] as String?,
      userName: user?['fullName'] as String?,
      userAvatarUrl: user?['avatarUrl'] as String?,
      vehicleName: vehicle?['name'] as String?,
      vehicleBrand: vehicle?['brand'] as String?,
      vehicleImage: (images != null && images.isNotEmpty)
          ? images.first as String?
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  ReviewEntity toEntity() => ReviewEntity(
    id: id,
    userId: userId,
    vehicleId: vehicleId,
    rating: rating,
    comment: comment,
    userName: userName,
    userAvatarUrl: userAvatarUrl,
    vehicleName: vehicleName,
    vehicleBrand: vehicleBrand,
    vehicleImage: vehicleImage,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}

class TrustScoreBreakdownModel {
  final TrustScoreBreakdown entity;
  TrustScoreBreakdownModel._(this.entity);

  factory TrustScoreBreakdownModel.fromJson(Map<String, dynamic> json) {
    final b = json['breakdown'] as Map<String, dynamic>;
    return TrustScoreBreakdownModel._(
      TrustScoreBreakdown(
        trustScore: json['trustScore'] as int,
        reviewsGiven: b['reviewsGiven'] as int,
        reviewsGivenBonus: b['reviewsGivenBonus'] as int,
        avgRatingReceived: (b['avgRatingReceived'] as num?)?.toDouble(),
        totalReviewsReceived: b['totalReviewsReceived'] as int,
        cancelledBookings: b['cancelledBookings'] as int,
        cancellationPenalty: b['cancellationPenalty'] as int,
        rejectedBookings: b['rejectedBookings'] as int,
        rejectionPenalty: b['rejectionPenalty'] as int,
        completedTrips: b['completedTrips'] as int,
        tripsWithIssues: b['tripsWithIssues'] as int,
        violationPenalty: b['violationPenalty'] as int,
      ),
    );
  }
}
