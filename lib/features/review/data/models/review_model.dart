import '../../domain/entities/review_entity.dart';

class ReviewModel extends ReviewEntity {
  const ReviewModel({
    required super.id,
    required super.userId,
    super.revieweeId,
    required super.vehicleId,
    super.tripId,
    super.bookingId,
    super.reviewType,
    required super.rating,
    super.comment,
    super.visibleAt,
    super.revealedAt,
    super.isRevealed,
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
    final trip = json['trip'] as Map<String, dynamic>?;
    final images = vehicle?['images'] as List<dynamic>?;
    return ReviewModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      revieweeId: json['revieweeId'] as String?,
      vehicleId: json['vehicleId'] as String,
      tripId: json['tripId'] as String?,
      bookingId: json['bookingId'] as String? ?? trip?['bookingId'] as String?,
      reviewType: json['reviewType'] as String? ?? 'RENTER_TO_OWNER',
      rating: json['rating'] as int,
      comment: json['comment'] as String?,
      visibleAt: json['visibleAt'] is String
          ? DateTime.tryParse(json['visibleAt'] as String)
          : null,
      revealedAt: json['revealedAt'] is String
          ? DateTime.tryParse(json['revealedAt'] as String)
          : null,
      isRevealed: json['isRevealed'] as bool? ?? true,
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
    revieweeId: revieweeId,
    vehicleId: vehicleId,
    tripId: tripId,
    bookingId: bookingId,
    reviewType: reviewType,
    rating: rating,
    comment: comment,
    visibleAt: visibleAt,
    revealedAt: revealedAt,
    isRevealed: isRevealed,
    userName: userName,
    userAvatarUrl: userAvatarUrl,
    vehicleName: vehicleName,
    vehicleBrand: vehicleBrand,
    vehicleImage: vehicleImage,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}

class BookingReviewStatusModel {
  final BookingReviewStatus entity;

  const BookingReviewStatusModel(this.entity);

  factory BookingReviewStatusModel.fromJson(Map<String, dynamic> json) {
    final ownReview = json['ownReview'];
    final receivedReview = json['receivedReview'];
    return BookingReviewStatusModel(
      BookingReviewStatus(
        bookingId: json['bookingId'] as String,
        submitted: json['submitted'] as bool? ?? false,
        counterpartSubmitted: json['counterpartSubmitted'] as bool? ?? false,
        isRevealed: json['isRevealed'] as bool? ?? false,
        ownReview: ownReview is Map<String, dynamic>
            ? ReviewModel.fromJson(ownReview).toEntity()
            : null,
        receivedReview: receivedReview is Map<String, dynamic>
            ? ReviewModel.fromJson(receivedReview).toEntity()
            : null,
        revealAt: json['revealAt'] is String
            ? DateTime.tryParse(json['revealAt'] as String)
            : null,
      ),
    );
  }
}

class TrustScoreBreakdownModel {
  final TrustScoreBreakdown entity;
  TrustScoreBreakdownModel._(this.entity);

  factory TrustScoreBreakdownModel.fromJson(Map<String, dynamic> json) {
    final b = json['breakdown'] as Map<String, dynamic>;

    final rawEvents = json['recentEvents'];
    final events = rawEvents is List
        ? rawEvents
              .whereType<Map>()
              .map((raw) => _parseEvent(Map<String, dynamic>.from(raw)))
              .whereType<TrustScoreEvent>()
              .toList()
        : const <TrustScoreEvent>[];

    final rawWarnings = json['activeWarnings'];
    final warnings = rawWarnings is List
        ? rawWarnings
              .whereType<Map>()
              .map((raw) => _parseWarning(Map<String, dynamic>.from(raw)))
              .whereType<TrustScoreWarning>()
              .toList()
        : const <TrustScoreWarning>[];

    return TrustScoreBreakdownModel._(
      TrustScoreBreakdown(
        trustScore: (json['trustScore'] as num).toInt(),
        reviewsGiven: b['reviewsGiven'] as int,
        reviewsGivenBonus: b['reviewsGivenBonus'] as int,
        avgRatingReceived: (b['avgRatingReceived'] as num?)?.toDouble(),
        totalReviewsReceived: b['totalReviewsReceived'] as int,
        cancelledBookings: b['cancelledBookings'] as int,
        cancellationPenalty: b['cancellationPenalty'] as int,
        cancellationWarnings: (b['cancellationWarnings'] as int?) ?? 0,
        rejectedBookings: b['rejectedBookings'] as int,
        rejectionPenalty: b['rejectionPenalty'] as int,
        rejectionWarnings: (b['rejectionWarnings'] as int?) ?? 0,
        completedTrips: b['completedTrips'] as int,
        tripsWithIssues: b['tripsWithIssues'] as int,
        violationPenalty: b['violationPenalty'] as int,
        violationWarnings: (b['violationWarnings'] as int?) ?? 0,
        recentEvents: events,
        activeWarnings: warnings,
      ),
    );
  }

  static TrustScoreEvent? _parseEvent(Map<String, dynamic> json) {
    final id = json['id'];
    final createdAt = json['createdAt'];
    if (id is! String || createdAt is! String) return null;
    return TrustScoreEvent(
      id: id,
      type: TrustScoreEventType.parse(json['type'] as String?),
      delta: (json['delta'] as num?)?.toDouble() ?? 0,
      scoreBefore: (json['scoreBefore'] as num?)?.toDouble() ?? 0,
      scoreAfter: (json['scoreAfter'] as num?)?.toDouble() ?? 0,
      reason: json['reason'] as String?,
      createdAt: DateTime.tryParse(createdAt) ?? DateTime.now(),
    );
  }

  static TrustScoreWarning? _parseWarning(Map<String, dynamic> json) {
    final id = json['id'];
    final createdAt = json['createdAt'];
    final expiresAt = json['expiresAt'];
    if (id is! String || createdAt is! String || expiresAt is! String) {
      return null;
    }
    return TrustScoreWarning(
      id: id,
      type: TrustScoreEventType.parse(json['type'] as String?),
      reason: json['reason'] as String?,
      createdAt: DateTime.tryParse(createdAt) ?? DateTime.now(),
      expiresAt: DateTime.tryParse(expiresAt) ?? DateTime.now(),
      penalizedAt: json['penalizedAt'] is String
          ? DateTime.tryParse(json['penalizedAt'] as String)
          : null,
    );
  }
}
