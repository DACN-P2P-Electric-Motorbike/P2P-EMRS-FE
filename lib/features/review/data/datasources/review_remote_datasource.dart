import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/review_model.dart';

abstract class ReviewRemoteDataSource {
  Future<ReviewModel> createReview({
    required String vehicleId,
    required int rating,
    String? comment,
    String? bookingId,
  });

  Future<List<ReviewModel>> getVehicleReviews(String vehicleId);
  Future<List<ReviewModel>> getMyReviews();
  Future<TrustScoreBreakdownModel> getTrustScoreBreakdown();
}

class ReviewRemoteDataSourceImpl implements ReviewRemoteDataSource {
  final DioClient _dioClient;

  ReviewRemoteDataSourceImpl({required DioClient dioClient})
    : _dioClient = dioClient;

  @override
  Future<ReviewModel> createReview({
    required String vehicleId,
    required int rating,
    String? comment,
    String? bookingId,
  }) async {
    try {
      final response = await _dioClient.post(
        ApiConstants.reviews,
        data: {
          'vehicleId': vehicleId,
          'rating': rating,
          if (comment != null && comment.isNotEmpty) 'comment': comment,
          if (bookingId != null) 'bookingId': bookingId,
        },
      );
      if (response.statusCode == 201) {
        return ReviewModel.fromJson(response.data as Map<String, dynamic>);
      }
      throw ServerException(
        message: 'Failed to create review',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw ServerException.fromDioException(e);
    }
  }

  @override
  Future<List<ReviewModel>> getVehicleReviews(String vehicleId) async {
    try {
      final response = await _dioClient.get(
        ApiConstants.vehicleReviews(vehicleId),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data
            .map((json) => ReviewModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      throw ServerException(
        message: 'Failed to get reviews',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw ServerException.fromDioException(e);
    }
  }

  @override
  Future<List<ReviewModel>> getMyReviews() async {
    try {
      final response = await _dioClient.get(ApiConstants.myReviews);
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data
            .map((json) => ReviewModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      throw ServerException(
        message: 'Failed to get my reviews',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw ServerException.fromDioException(e);
    }
  }

  @override
  Future<TrustScoreBreakdownModel> getTrustScoreBreakdown() async {
    try {
      final response = await _dioClient.get(ApiConstants.trustScore);
      if (response.statusCode == 200) {
        return TrustScoreBreakdownModel.fromJson(
          response.data as Map<String, dynamic>,
        );
      }
      throw ServerException(
        message: 'Failed to get trust score',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw ServerException.fromDioException(e);
    }
  }
}
