import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/financial_summary_model.dart';

abstract class FinancialRemoteDataSource {
  Future<FinancialSummaryModel> getBookingFinancialSummary(String bookingId);

  Future<FinancialSummaryModel> createManualPostTripCharge({
    required String bookingId,
    required String type,
    required double amount,
    required String description,
    double? quantity,
    double? unitPrice,
    List<String>? evidenceUrls,
  });

  Future<FinancialSummaryModel> disputePostTripCharge({
    required String chargeId,
    required String reason,
    List<String>? evidenceUrls,
  });
}

class FinancialRemoteDataSourceImpl implements FinancialRemoteDataSource {
  final DioClient _dioClient;

  FinancialRemoteDataSourceImpl({required DioClient dioClient})
    : _dioClient = dioClient;

  @override
  Future<FinancialSummaryModel> getBookingFinancialSummary(
    String bookingId,
  ) async {
    try {
      final response = await _dioClient.get(
        ApiConstants.financialByBooking(bookingId),
      );
      if (response.statusCode == 200) {
        return FinancialSummaryModel.fromJson(
          _responseMap(response.data, 'Failed to get financial summary'),
        );
      }
      throw ServerException(
        message: 'Failed to get financial summary',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw ServerException.fromDioException(e);
    }
  }

  @override
  Future<FinancialSummaryModel> createManualPostTripCharge({
    required String bookingId,
    required String type,
    required double amount,
    required String description,
    double? quantity,
    double? unitPrice,
    List<String>? evidenceUrls,
  }) async {
    try {
      final response = await _dioClient.post(
        ApiConstants.financialChargesByBooking(bookingId),
        data: {
          'type': type,
          'amount': amount,
          'description': description,
          if (quantity != null) 'quantity': quantity,
          if (unitPrice != null) 'unitPrice': unitPrice,
          if (evidenceUrls != null) 'evidenceUrls': evidenceUrls,
        },
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        return FinancialSummaryModel.fromJson(
          _responseMap(response.data, 'Failed to create post-trip charge'),
        );
      }
      throw ServerException(
        message: 'Failed to create post-trip charge',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw ServerException.fromDioException(e);
    }
  }

  @override
  Future<FinancialSummaryModel> disputePostTripCharge({
    required String chargeId,
    required String reason,
    List<String>? evidenceUrls,
  }) async {
    try {
      final response = await _dioClient.post(
        ApiConstants.disputeFinancialCharge(chargeId),
        data: {
          'reason': reason,
          if (evidenceUrls != null) 'evidenceUrls': evidenceUrls,
        },
      );
      if (response.statusCode == 200) {
        return FinancialSummaryModel.fromJson(
          _responseMap(response.data, 'Failed to dispute post-trip charge'),
        );
      }
      throw ServerException(
        message: 'Failed to dispute post-trip charge',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw ServerException.fromDioException(e);
    }
  }

  Map<String, dynamic> _responseMap(dynamic data, String fallbackMessage) {
    final unwrapped = data is Map && data['data'] is Map ? data['data'] : data;

    if (unwrapped is Map<String, dynamic>) {
      return unwrapped;
    }

    if (unwrapped is Map) {
      return Map<String, dynamic>.from(unwrapped);
    }

    if (unwrapped is String) {
      final message = unwrapped.trim().isEmpty ? fallbackMessage : unwrapped;
      throw ServerException(message: message);
    }

    throw ServerException(message: fallbackMessage);
  }
}
