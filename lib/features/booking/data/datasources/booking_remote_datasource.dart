import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/utils/vietnam_time.dart';
import '../models/booking_model.dart';

/// Abstract class for booking remote data source
abstract class BookingRemoteDataSource {
  /// Create booking (renter)
  Future<BookingModel> createBooking({
    required String vehicleId,
    required DateTime startTime,
    required DateTime endTime,
    String? notes,
  });

  /// Get renter bookings
  Future<List<BookingModel>> getRenterBookings({String? status});

  /// Get upcoming bookings
  Future<List<BookingModel>> getUpcomingBookings();

  /// Get booking history
  Future<List<BookingModel>> getBookingHistory();

  /// Get booking by ID
  Future<BookingModel> getBookingById(String bookingId);

  /// Cancel booking
  Future<BookingModel> cancelBooking(String bookingId, String reason);

  /// Get owner bookings
  Future<List<BookingModel>> getOwnerBookings({String? status});

  /// Get pending bookings (owner)
  Future<List<BookingModel>> getPendingBookings();

  /// Approve booking (owner)
  Future<BookingModel> approveBooking(String bookingId, {String? message});

  /// Reject booking (owner)
  Future<BookingModel> rejectBooking(String bookingId, String reason);
}

/// Implementation using DioClient
class BookingRemoteDataSourceImpl implements BookingRemoteDataSource {
  final DioClient _dioClient;

  BookingRemoteDataSourceImpl({required DioClient dioClient})
    : _dioClient = dioClient;

  @override
  Future<BookingModel> createBooking({
    required String vehicleId,
    required DateTime startTime,
    required DateTime endTime,
    String? notes,
  }) async {
    try {
      final response = await _dioClient.post(
        '/bookings',
        data: {
          'vehicleId': vehicleId,
          'startTime': VietnamTime.toApiIsoString(startTime),
          'endTime': VietnamTime.toApiIsoString(endTime),
          if (notes != null) 'notes': notes,
        },
      );

      if (response.statusCode == 201) {
        return BookingModel.fromJson(
          await _withPaymentStatus(
            Map<String, dynamic>.from(response.data as Map),
          ),
        );
      }

      throw ServerException(
        message: 'Failed to create booking',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw ServerException.fromDioException(e);
    }
  }

  @override
  Future<List<BookingModel>> getRenterBookings({String? status}) async {
    try {
      final queryParams = status != null ? {'status': status} : null;
      final response = await _dioClient.get(
        '/bookings',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        return _bookingModelsFromList(data);
      }

      throw ServerException(
        message: 'Failed to get bookings',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw ServerException.fromDioException(e);
    }
  }

  @override
  Future<List<BookingModel>> getUpcomingBookings() async {
    try {
      final response = await _dioClient.get('/bookings/upcoming');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        return _bookingModelsFromList(data);
      }

      throw ServerException(
        message: 'Failed to get upcoming bookings',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw ServerException.fromDioException(e);
    }
  }

  @override
  Future<List<BookingModel>> getBookingHistory() async {
    try {
      final response = await _dioClient.get('/bookings/history');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        return _bookingModelsFromList(data);
      }

      throw ServerException(
        message: 'Failed to get booking history',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw ServerException.fromDioException(e);
    }
  }

  @override
  Future<BookingModel> getBookingById(String bookingId) async {
    try {
      final response = await _dioClient.get('/bookings/$bookingId');

      if (response.statusCode == 200) {
        return BookingModel.fromJson(
          await _withPaymentStatus(
            Map<String, dynamic>.from(response.data as Map),
          ),
        );
      }

      throw ServerException(
        message: 'Booking not found',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw ServerException.fromDioException(e);
    }
  }

  @override
  Future<BookingModel> cancelBooking(String bookingId, String reason) async {
    try {
      final response = await _dioClient.patch(
        '/bookings/$bookingId/cancel',
        data: {'reason': reason},
      );

      if (response.statusCode == 200) {
        return BookingModel.fromJson(
          await _withPaymentStatus(
            Map<String, dynamic>.from(response.data as Map),
          ),
        );
      }

      throw ServerException(
        message: 'Failed to cancel booking',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw ServerException.fromDioException(e);
    }
  }

  @override
  Future<List<BookingModel>> getOwnerBookings({String? status}) async {
    try {
      final queryParams = status != null ? {'status': status} : null;
      final response = await _dioClient.get(
        '/owner/bookings',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        return _bookingModelsFromList(data);
      }

      throw ServerException(
        message: 'Failed to get owner bookings',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw ServerException.fromDioException(e);
    }
  }

  @override
  Future<List<BookingModel>> getPendingBookings() async {
    try {
      final response = await _dioClient.get('/owner/bookings/pending');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        return _bookingModelsFromList(data);
      }

      throw ServerException(
        message: 'Failed to get pending bookings',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw ServerException.fromDioException(e);
    }
  }

  @override
  Future<BookingModel> approveBooking(
    String bookingId, {
    String? message,
  }) async {
    try {
      final response = await _dioClient.patch(
        '/owner/bookings/$bookingId/approve',
        data: {if (message != null) 'message': message},
      );

      if (response.statusCode == 200) {
        return BookingModel.fromJson(
          await _withPaymentStatus(
            Map<String, dynamic>.from(response.data as Map),
          ),
        );
      }

      throw ServerException(
        message: 'Failed to approve booking',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw ServerException.fromDioException(e);
    }
  }

  @override
  Future<BookingModel> rejectBooking(String bookingId, String reason) async {
    try {
      final response = await _dioClient.patch(
        '/owner/bookings/$bookingId/reject',
        data: {'reason': reason},
      );

      if (response.statusCode == 200) {
        return BookingModel.fromJson(
          await _withPaymentStatus(
            Map<String, dynamic>.from(response.data as Map),
          ),
        );
      }

      throw ServerException(
        message: 'Failed to reject booking',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw ServerException.fromDioException(e);
    }
  }

  Future<List<BookingModel>> _bookingModelsFromList(List<dynamic> data) async {
    final enriched = await Future.wait(
      data.map(
        (json) => _withPaymentStatus(Map<String, dynamic>.from(json as Map)),
      ),
    );
    return enriched.map(BookingModel.fromJson).toList();
  }

  Future<Map<String, dynamic>> _withPaymentStatus(
    Map<String, dynamic> bookingJson,
  ) async {
    if (_paymentStatusFromBookingJson(bookingJson) != null) {
      return bookingJson;
    }

    final bookingStatus = (bookingJson['status'] as String? ?? '')
        .toUpperCase();
    const statusesThatNeedPayment = {'CONFIRMED', 'ONGOING', 'COMPLETED'};
    if (!statusesThatNeedPayment.contains(bookingStatus)) {
      return bookingJson;
    }

    final bookingId = bookingJson['id'];
    if (bookingId is! String || bookingId.isEmpty) {
      return bookingJson;
    }

    final paymentStatus = await _fetchPaymentStatus(bookingId);
    if (paymentStatus == null) {
      return bookingJson;
    }

    return {...bookingJson, 'paymentStatus': paymentStatus};
  }

  String? _paymentStatusFromBookingJson(Map<String, dynamic> bookingJson) {
    final directStatus = bookingJson['paymentStatus'];
    if (directStatus is String && directStatus.isNotEmpty) {
      return directStatus;
    }

    final payment = bookingJson['payment'];
    if (payment is Map) {
      final nestedStatus = payment['status'];
      if (nestedStatus is String && nestedStatus.isNotEmpty) {
        return nestedStatus;
      }
    }

    return null;
  }

  Future<String?> _fetchPaymentStatus(String bookingId) async {
    try {
      final response = await _dioClient.get(
        '/payments/by-booking',
        queryParameters: {'bookingId': bookingId},
      );
      if (response.statusCode != 200 || response.data == null) {
        return null;
      }

      final data = Map<String, dynamic>.from(response.data as Map);
      final status = data['status'];
      return status is String && status.isNotEmpty ? status : null;
    } catch (_) {
      return null;
    }
  }
}
