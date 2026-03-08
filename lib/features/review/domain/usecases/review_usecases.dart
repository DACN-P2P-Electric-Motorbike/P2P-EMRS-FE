import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/review_entity.dart';
import '../repositories/review_repository.dart';

class CreateReviewParams {
  final String vehicleId;
  final int rating;
  final String? comment;
  final String? bookingId;

  const CreateReviewParams({
    required this.vehicleId,
    required this.rating,
    this.comment,
    this.bookingId,
  });
}

class CreateReviewUseCase implements UseCase<ReviewEntity, CreateReviewParams> {
  final ReviewRepository repository;
  CreateReviewUseCase(this.repository);

  @override
  Future<Either<Failure, ReviewEntity>> call(CreateReviewParams params) {
    return repository.createReview(
      vehicleId: params.vehicleId,
      rating: params.rating,
      comment: params.comment,
      bookingId: params.bookingId,
    );
  }
}

class GetVehicleReviewsParams {
  final String vehicleId;
  const GetVehicleReviewsParams(this.vehicleId);
}

class GetVehicleReviewsUseCase
    implements UseCase<List<ReviewEntity>, GetVehicleReviewsParams> {
  final ReviewRepository repository;
  GetVehicleReviewsUseCase(this.repository);

  @override
  Future<Either<Failure, List<ReviewEntity>>> call(
    GetVehicleReviewsParams params,
  ) {
    return repository.getVehicleReviews(params.vehicleId);
  }
}

class GetMyReviewsUseCase implements UseCase<List<ReviewEntity>, NoParams> {
  final ReviewRepository repository;
  GetMyReviewsUseCase(this.repository);

  @override
  Future<Either<Failure, List<ReviewEntity>>> call(NoParams params) {
    return repository.getMyReviews();
  }
}

class GetTrustScoreBreakdownUseCase
    implements UseCase<TrustScoreBreakdown, NoParams> {
  final ReviewRepository repository;
  GetTrustScoreBreakdownUseCase(this.repository);

  @override
  Future<Either<Failure, TrustScoreBreakdown>> call(NoParams params) {
    return repository.getTrustScoreBreakdown();
  }
}
