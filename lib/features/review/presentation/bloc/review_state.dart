import 'package:equatable/equatable.dart';
import '../../domain/entities/review_entity.dart';

abstract class ReviewState extends Equatable {
  const ReviewState();

  @override
  List<Object?> get props => [];
}

class ReviewInitial extends ReviewState {
  const ReviewInitial();
}

class ReviewLoading extends ReviewState {
  const ReviewLoading();
}

class ReviewsLoaded extends ReviewState {
  final List<ReviewEntity> reviews;
  const ReviewsLoaded(this.reviews);

  @override
  List<Object?> get props => [reviews];
}

class MyReviewsLoaded extends ReviewState {
  final List<ReviewEntity> reviews;
  const MyReviewsLoaded(this.reviews);

  @override
  List<Object?> get props => [reviews];
}

class TrustScoreLoaded extends ReviewState {
  final TrustScoreBreakdown breakdown;
  const TrustScoreLoaded(this.breakdown);

  @override
  List<Object?> get props => [breakdown];
}

class ReviewCreated extends ReviewState {
  final ReviewEntity review;
  const ReviewCreated(this.review);

  @override
  List<Object?> get props => [review];
}

class ReviewFailure extends ReviewState {
  final String message;
  const ReviewFailure(this.message);

  @override
  List<Object?> get props => [message];
}
