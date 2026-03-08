import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/review_entity.dart';

abstract class ReviewRepository {
  Future<Either<Failure, ReviewEntity>> createReview({
    required String vehicleId,
    required int rating,
    String? comment,
    String? bookingId,
  });

  Future<Either<Failure, List<ReviewEntity>>> getVehicleReviews(
    String vehicleId,
  );

  Future<Either<Failure, List<ReviewEntity>>> getMyReviews();

  Future<Either<Failure, TrustScoreBreakdown>> getTrustScoreBreakdown();
}
