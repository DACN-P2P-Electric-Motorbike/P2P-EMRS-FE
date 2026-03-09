import 'package:equatable/equatable.dart';

abstract class ReviewEvent extends Equatable {
  const ReviewEvent();

  @override
  List<Object?> get props => [];
}

class CreateReviewEvent extends ReviewEvent {
  final String vehicleId;
  final int rating;
  final String? comment;
  final String? bookingId;

  const CreateReviewEvent({
    required this.vehicleId,
    required this.rating,
    this.comment,
    this.bookingId,
  });

  @override
  List<Object?> get props => [vehicleId, rating, comment, bookingId];
}

class LoadVehicleReviewsEvent extends ReviewEvent {
  final String vehicleId;
  const LoadVehicleReviewsEvent(this.vehicleId);

  @override
  List<Object?> get props => [vehicleId];
}

class LoadMyReviewsEvent extends ReviewEvent {
  const LoadMyReviewsEvent();
}

class LoadTrustScoreEvent extends ReviewEvent {
  const LoadTrustScoreEvent();
}

class ResetReviewStateEvent extends ReviewEvent {
  const ResetReviewStateEvent();
}
