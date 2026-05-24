import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/incident_report_model.dart';

abstract class IncidentRemoteDataSource {
  Future<List<IncidentReportModel>> getBookingIncidents(String bookingId);

  Future<IncidentReportModel> createIncidentReport({
    required String bookingId,
    String? tripId,
    String? postTripChargeId,
    required String category,
    required String severity,
    required String description,
    List<String>? evidenceUrls,
    List<String>? handoverPhotoIds,
  });
}

class IncidentRemoteDataSourceImpl implements IncidentRemoteDataSource {
  final DioClient _dioClient;

  IncidentRemoteDataSourceImpl({required DioClient dioClient})
    : _dioClient = dioClient;

  @override
  Future<List<IncidentReportModel>> getBookingIncidents(
    String bookingId,
  ) async {
    try {
      final response = await _dioClient.get(
        ApiConstants.incidentsByBooking(bookingId),
      );
      if (response.statusCode == 200) {
        final list = _responseList(
          response.data,
          'Failed to get incident reports',
        );
        return list
            .whereType<Map>()
            .map(
              (item) =>
                  IncidentReportModel.fromJson(Map<String, dynamic>.from(item)),
            )
            .toList();
      }
      throw ServerException(
        message: 'Failed to get incident reports',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw ServerException.fromDioException(e);
    }
  }

  @override
  Future<IncidentReportModel> createIncidentReport({
    required String bookingId,
    String? tripId,
    String? postTripChargeId,
    required String category,
    required String severity,
    required String description,
    List<String>? evidenceUrls,
    List<String>? handoverPhotoIds,
  }) async {
    try {
      final response = await _dioClient.post(
        ApiConstants.incidents,
        data: {
          'bookingId': bookingId,
          if (tripId != null) 'tripId': tripId,
          if (postTripChargeId != null) 'postTripChargeId': postTripChargeId,
          'category': category,
          'severity': severity,
          'description': description,
          if (evidenceUrls != null) 'evidenceUrls': evidenceUrls,
          if (handoverPhotoIds != null) 'handoverPhotoIds': handoverPhotoIds,
        },
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        return IncidentReportModel.fromJson(
          _responseMap(response.data, 'Failed to create incident report'),
        );
      }
      throw ServerException(
        message: 'Failed to create incident report',
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

  List<dynamic> _responseList(dynamic data, String fallbackMessage) {
    final unwrapped = data is Map && data['data'] is List ? data['data'] : data;

    if (unwrapped is List) {
      return unwrapped;
    }

    if (unwrapped is String) {
      final message = unwrapped.trim().isEmpty ? fallbackMessage : unwrapped;
      throw ServerException(message: message);
    }

    throw ServerException(message: fallbackMessage);
  }
}
