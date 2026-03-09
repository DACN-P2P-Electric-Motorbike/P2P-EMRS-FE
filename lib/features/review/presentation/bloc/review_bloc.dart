import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/review_usecases.dart';
import 'review_event.dart';
import 'review_state.dart';

class ReviewBloc extends Bloc<ReviewEvent, ReviewState> {
  final CreateReviewUseCase _createReview;
  final GetVehicleReviewsUseCase _getVehicleReviews;
  final GetMyReviewsUseCase _getMyReviews;
  final GetTrustScoreBreakdownUseCase _getTrustScore;

  ReviewBloc({
    required CreateReviewUseCase createReview,
    required GetVehicleReviewsUseCase getVehicleReviews,
    required GetMyReviewsUseCase getMyReviews,
    required GetTrustScoreBreakdownUseCase getTrustScore,
  }) : _createReview = createReview,
       _getVehicleReviews = getVehicleReviews,
       _getMyReviews = getMyReviews,
       _getTrustScore = getTrustScore,
       super(const ReviewInitial()) {
    on<CreateReviewEvent>(_onCreateReview);
    on<LoadVehicleReviewsEvent>(_onLoadVehicleReviews);
    on<LoadMyReviewsEvent>(_onLoadMyReviews);
    on<LoadTrustScoreEvent>(_onLoadTrustScore);
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
        bookingId: event.bookingId,
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

  Future<void> _onLoadMyReviews(
    LoadMyReviewsEvent event,
    Emitter<ReviewState> emit,
  ) async {
    emit(const ReviewLoading());
    final result = await _getMyReviews(const NoParams());
    result.fold(
      (failure) => emit(ReviewFailure(failure.message)),
      (reviews) => emit(MyReviewsLoaded(reviews)),
    );
  }

  Future<void> _onLoadTrustScore(
    LoadTrustScoreEvent event,
    Emitter<ReviewState> emit,
  ) async {
    emit(const ReviewLoading());
    final result = await _getTrustScore(const NoParams());
    result.fold(
      (failure) => emit(ReviewFailure(failure.message)),
      (breakdown) => emit(TrustScoreLoaded(breakdown)),
    );
  }

  void _onReset(ResetReviewStateEvent event, Emitter<ReviewState> emit) {
    emit(const ReviewInitial());
  }
}
