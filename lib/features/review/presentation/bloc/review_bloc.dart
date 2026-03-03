import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/review_usecases.dart';
import 'review_event.dart';
import 'review_state.dart';

class ReviewBloc extends Bloc<ReviewEvent, ReviewState> {
  final CreateReviewUseCase _createReview;
  final GetVehicleReviewsUseCase _getVehicleReviews;

  ReviewBloc({
    required CreateReviewUseCase createReview,
    required GetVehicleReviewsUseCase getVehicleReviews,
  }) : _createReview = createReview,
       _getVehicleReviews = getVehicleReviews,
       super(const ReviewInitial()) {
    on<CreateReviewEvent>(_onCreateReview);
    on<LoadVehicleReviewsEvent>(_onLoadVehicleReviews);
    on<ResetReviewStateEvent>(_onReset);
  }

  Future<void> _onCreateReview(
    CreateReviewEvent event,
    Emitter<ReviewState> emit,
  ) async {
    emit(const ReviewLoading());
    final result = await _createReview(
      CreateReviewParams(
        vehicleId: event.vehicleId,
        rating: event.rating,
        comment: event.comment,
      ),
    );
    result.fold(
      (failure) => emit(ReviewFailure(failure.message)),
      (review) => emit(ReviewCreated(review)),
    );
  }

  Future<void> _onLoadVehicleReviews(
    LoadVehicleReviewsEvent event,
    Emitter<ReviewState> emit,
  ) async {
    emit(const ReviewLoading());
    final result = await _getVehicleReviews(
      GetVehicleReviewsParams(event.vehicleId),
    );
    result.fold(
      (failure) => emit(ReviewFailure(failure.message)),
      (reviews) => emit(ReviewsLoaded(reviews)),
    );
  }

  void _onReset(ResetReviewStateEvent event, Emitter<ReviewState> emit) {
    emit(const ReviewInitial());
  }
}
