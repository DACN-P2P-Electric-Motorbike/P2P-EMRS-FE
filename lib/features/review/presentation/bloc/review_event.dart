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

  const CreateReviewEvent({
    required this.vehicleId,
    required this.rating,
    this.comment,
  });

  @override
  List<Object?> get props => [vehicleId, rating, comment];
}

class LoadVehicleReviewsEvent extends ReviewEvent {
  final String vehicleId;
  const LoadVehicleReviewsEvent(this.vehicleId);

  @override
  List<Object?> get props => [vehicleId];
}

class ResetReviewStateEvent extends ReviewEvent {
  const ResetReviewStateEvent();
}
