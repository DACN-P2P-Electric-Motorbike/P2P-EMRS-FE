import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/review_entity.dart';
import '../../domain/repositories/review_repository.dart';
import '../datasources/review_remote_datasource.dart';

class ReviewRepositoryImpl implements ReviewRepository {
  final ReviewRemoteDataSource _remoteDataSource;

  ReviewRepositoryImpl({required ReviewRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, ReviewEntity>> createReview({
    required String vehicleId,
    required int rating,
    String? comment,
    String? bookingId,
  }) async {
    try {
      final review = await _remoteDataSource.createReview(
        vehicleId: vehicleId,
        rating: rating,
        comment: comment,
        bookingId: bookingId,
      );
      return Right(review.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on ConnectionException {
      return const Left(ConnectionFailure());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ReviewEntity>>> getVehicleReviews(
    String vehicleId,
  ) async {
    try {
      final reviews = await _remoteDataSource.getVehicleReviews(vehicleId);
      return Right(reviews.map((r) => r.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on ConnectionException {
      return const Left(ConnectionFailure());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ReviewEntity>>> getMyReviews() async {
    try {
      final reviews = await _remoteDataSource.getMyReviews();
      return Right(reviews.map((r) => r.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on ConnectionException {
      return const Left(ConnectionFailure());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, TrustScoreBreakdown>> getTrustScoreBreakdown() async {
    try {
      final model = await _remoteDataSource.getTrustScoreBreakdown();
      return Right(model.entity);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on ConnectionException {
      return const Left(ConnectionFailure());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
