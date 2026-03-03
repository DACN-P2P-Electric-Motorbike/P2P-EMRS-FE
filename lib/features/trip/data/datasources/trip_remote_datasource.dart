import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/trip_model.dart';

abstract class TripRemoteDataSource {
  Future<TripModel> startTrip({
    required String bookingId,
    double? startLatitude,
    double? startLongitude,
    String? startAddress,
    double? startBattery,
  });

  Future<TripModel> endTrip({
    required String tripId,
    double? endLatitude,
    double? endLongitude,
    String? endAddress,
    double? endBattery,
    bool hasIssues = false,
    String? issueDescription,
  });

  Future<TripModel?> getActiveTrip();

  Future<List<TripModel>> getTripHistory();

  Future<TripModel> getTripById(String tripId);
}

class TripRemoteDataSourceImpl implements TripRemoteDataSource {
  final DioClient _dioClient;

  TripRemoteDataSourceImpl({required DioClient dioClient})
    : _dioClient = dioClient;

  @override
  Future<TripModel> startTrip({
    required String bookingId,
    double? startLatitude,
    double? startLongitude,
    String? startAddress,
    double? startBattery,
  }) async {
    try {
      final response = await _dioClient.post(
        '/trips/start',
        data: {
          'bookingId': bookingId,
          if (startLatitude != null) 'startLatitude': startLatitude,
          if (startLongitude != null) 'startLongitude': startLongitude,
          if (startAddress != null) 'startAddress': startAddress,
          if (startBattery != null) 'startBattery': startBattery,
        },
      );
      if (response.statusCode == 201) {
        return TripModel.fromJson(response.data as Map<String, dynamic>);
      }
      throw ServerException(
        message: 'Failed to start trip',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw ServerException.fromDioException(e);
    }
  }

  @override
  Future<TripModel> endTrip({
    required String tripId,
    double? endLatitude,
    double? endLongitude,
    String? endAddress,
    double? endBattery,
    bool hasIssues = false,
    String? issueDescription,
  }) async {
    try {
      final response = await _dioClient.patch(
        '/trips/$tripId/end',
        data: {
          if (endLatitude != null) 'endLatitude': endLatitude,
          if (endLongitude != null) 'endLongitude': endLongitude,
          if (endAddress != null) 'endAddress': endAddress,
          if (endBattery != null) 'endBattery': endBattery,
          'hasIssues': hasIssues,
          if (issueDescription != null) 'issueDescription': issueDescription,
        },
      );
      if (response.statusCode == 200) {
        return TripModel.fromJson(response.data as Map<String, dynamic>);
      }
      throw ServerException(
        message: 'Failed to end trip',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw ServerException.fromDioException(e);
    }
  }

  @override
  Future<TripModel?> getActiveTrip() async {
    try {
      final response = await _dioClient.get('/trips/active');
      if (response.statusCode == 200) {
        if (response.data == null) return null;
        return TripModel.fromJson(response.data as Map<String, dynamic>);
      }
      throw ServerException(
        message: 'Failed to get active trip',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw ServerException.fromDioException(e);
    }
  }

  @override
  Future<List<TripModel>> getTripHistory() async {
    try {
      final response = await _dioClient.get('/trips/history');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data
            .map((json) => TripModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      throw ServerException(
        message: 'Failed to get trip history',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw ServerException.fromDioException(e);
    }
  }

  @override
  Future<TripModel> getTripById(String tripId) async {
    try {
      final response = await _dioClient.get('/trips/$tripId');
      if (response.statusCode == 200) {
        return TripModel.fromJson(response.data as Map<String, dynamic>);
      }
      throw ServerException(
        message: 'Trip not found',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw ServerException.fromDioException(e);
    }
  }
}
