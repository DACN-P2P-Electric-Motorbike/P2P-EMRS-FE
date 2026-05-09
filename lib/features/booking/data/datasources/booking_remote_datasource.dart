import 'dart:async';

import 'package:dio/dio.dart';
import '../../../../core/cache/hive_cache_service.dart';
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
  final HiveCacheService _cache;

  BookingRemoteDataSourceImpl({
    required DioClient dioClient,
    required HiveCacheService cache,
  }) : _dioClient = dioClient,
       _cache = cache;

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
        final booking = BookingModel.fromJson(
          await _withPaymentStatus(
            Map<String, dynamic>.from(response.data as Map),
          ),
        );
        await _writeBookingAndInvalidateLists(booking);
        return booking;
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
    final queryParams = status != null ? {'status': status} : null;
    final cacheKey = 'bookings.renter:${status ?? 'all'}';
    final cached = await _cachedBookingList(cacheKey);
    if (cached != null) {
      unawaited(
        _refreshBookingList(
          cacheKey,
          '/bookings',
          queryParameters: queryParams,
          fallbackMessage: 'Failed to get bookings',
        ),
      );
      return cached;
    }

    return _fetchAndCacheBookingList(
      cacheKey,
      '/bookings',
      queryParameters: queryParams,
      fallbackMessage: 'Failed to get bookings',
    );
  }

  @override
  Future<List<BookingModel>> getUpcomingBookings() async {
    const cacheKey = 'bookings.upcoming';
    final cached = await _cachedBookingList(cacheKey);
    if (cached != null) {
      unawaited(
        _refreshBookingList(
          cacheKey,
          '/bookings/upcoming',
          fallbackMessage: 'Failed to get upcoming bookings',
        ),
      );
      return cached;
    }

    return _fetchAndCacheBookingList(
      cacheKey,
      '/bookings/upcoming',
      fallbackMessage: 'Failed to get upcoming bookings',
    );
  }

  @override
  Future<List<BookingModel>> getBookingHistory() async {
    const cacheKey = 'bookings.history';
    final cached = await _cachedBookingList(cacheKey);
    if (cached != null) {
      unawaited(
        _refreshBookingList(
          cacheKey,
          '/bookings/history',
          fallbackMessage: 'Failed to get booking history',
        ),
      );
      return cached;
    }

    return _fetchAndCacheBookingList(
      cacheKey,
      '/bookings/history',
      fallbackMessage: 'Failed to get booking history',
    );
  }

  @override
  Future<BookingModel> getBookingById(String bookingId) async {
    final cacheKey = 'bookings.detail:$bookingId';
    final cached = await _cache.read<Map<dynamic, dynamic>>(cacheKey);
    if (cached != null) {
      unawaited(_refreshBookingDetail(cacheKey, bookingId));
      return BookingModel.fromJson(Map<String, dynamic>.from(cached));
    }

    try {
      final response = await _dioClient.get('/bookings/$bookingId');

      if (response.statusCode == 200) {
        final booking = BookingModel.fromJson(
          await _withPaymentStatus(
            Map<String, dynamic>.from(response.data as Map),
          ),
        );
        await _cache.write(cacheKey, booking.toJson());
        return booking;
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
        final booking = BookingModel.fromJson(
          await _withPaymentStatus(
            Map<String, dynamic>.from(response.data as Map),
          ),
        );
        await _writeBookingAndInvalidateLists(booking);
        return booking;
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
    final queryParams = status != null ? {'status': status} : null;
    final cacheKey = 'bookings.owner:${status ?? 'all'}';
    final cached = await _cachedBookingList(cacheKey);
    if (cached != null) {
      unawaited(
        _refreshBookingList(
          cacheKey,
          '/owner/bookings',
          queryParameters: queryParams,
          fallbackMessage: 'Failed to get owner bookings',
        ),
      );
      return cached;
    }

    return _fetchAndCacheBookingList(
      cacheKey,
      '/owner/bookings',
      queryParameters: queryParams,
      fallbackMessage: 'Failed to get owner bookings',
    );
  }

  @override
  Future<List<BookingModel>> getPendingBookings() async {
    const cacheKey = 'bookings.owner.pending';
    final cached = await _cachedBookingList(cacheKey);
    if (cached != null) {
      unawaited(
        _refreshBookingList(
          cacheKey,
          '/owner/bookings/pending',
          fallbackMessage: 'Failed to get pending bookings',
        ),
      );
      return cached;
    }

    return _fetchAndCacheBookingList(
      cacheKey,
      '/owner/bookings/pending',
      fallbackMessage: 'Failed to get pending bookings',
    );
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
        final booking = BookingModel.fromJson(
          await _withPaymentStatus(
            Map<String, dynamic>.from(response.data as Map),
          ),
        );
        await _writeBookingAndInvalidateLists(booking);
        return booking;
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
        final booking = BookingModel.fromJson(
          await _withPaymentStatus(
            Map<String, dynamic>.from(response.data as Map),
          ),
        );
        await _writeBookingAndInvalidateLists(booking);
        return booking;
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

  Future<List<BookingModel>?> _cachedBookingList(String cacheKey) async {
    final cached = await _cache.read<List<dynamic>>(cacheKey);
    if (cached == null) return null;
    return cached
        .whereType<Map>()
        .map((json) => BookingModel.fromJson(Map<String, dynamic>.from(json)))
        .toList();
  }

  Future<List<BookingModel>> _fetchAndCacheBookingList(
    String cacheKey,
    String path, {
    Map<String, dynamic>? queryParameters,
    required String fallbackMessage,
  }) async {
    try {
      final response = await _dioClient.get(
        path,
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200) {
        final models = await _bookingModelsFromList(
          response.data as List<dynamic>,
        );
        await _cache.write(cacheKey, models.map((b) => b.toJson()).toList());
        return models;
      }

      throw ServerException(
        message: fallbackMessage,
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw ServerException.fromDioException(e);
    }
  }

  Future<void> _refreshBookingList(
    String cacheKey,
    String path, {
    Map<String, dynamic>? queryParameters,
    required String fallbackMessage,
  }) async {
    try {
      await _fetchAndCacheBookingList(
        cacheKey,
        path,
        queryParameters: queryParameters,
        fallbackMessage: fallbackMessage,
      );
    } catch (_) {}
  }

  Future<void> _refreshBookingDetail(String cacheKey, String bookingId) async {
    try {
      final response = await _dioClient.get('/bookings/$bookingId');
      if (response.statusCode != 200) return;
      final booking = BookingModel.fromJson(
        await _withPaymentStatus(
          Map<String, dynamic>.from(response.data as Map),
        ),
      );
      await _cache.write(cacheKey, booking.toJson());
    } catch (_) {}
  }

  Future<void> _writeBookingAndInvalidateLists(BookingModel booking) async {
    await _cache.write('bookings.detail:${booking.id}', booking.toJson());
    await _cache.deleteByPrefix('bookings.renter:');
    await _cache.delete('bookings.upcoming');
    await _cache.delete('bookings.history');
    await _cache.deleteByPrefix('bookings.owner:');
    await _cache.delete('bookings.owner.pending');
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
