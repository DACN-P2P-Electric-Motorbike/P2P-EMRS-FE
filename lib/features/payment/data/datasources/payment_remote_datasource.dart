import 'package:dio/dio.dart';
import '../../../../core/cache/hive_cache_service.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/payment_model.dart';
import '../../domain/entities/owner_earnings_entity.dart';

abstract class PaymentRemoteDataSource {
  Future<PaymentModel> createPayment({
    required String bookingId,
    required String method,
  });

  Future<PaymentModel?> getPaymentByBookingId(String bookingId);

  Future<PaymentModel> getPaymentById(String paymentId);

  Future<PaymentModel> simulateSuccess(String paymentId);

  Future<Map<String, String>> initiatePayOS(String paymentId);

  Future<Map<String, String>> initiateMoMo(String paymentId);

  Future<PaymentModel> refund(String paymentId, String otp);

  Future<OwnerEarningsEntity> getOwnerEarnings();
}

class PaymentRemoteDataSourceImpl implements PaymentRemoteDataSource {
  final DioClient _dioClient;
  final HiveCacheService _cache;

  PaymentRemoteDataSourceImpl({
    required DioClient dioClient,
    required HiveCacheService cache,
  }) : _dioClient = dioClient,
       _cache = cache;

  @override
  Future<PaymentModel> createPayment({
    required String bookingId,
    required String method,
  }) async {
    try {
      final response = await _dioClient.post(
        '/payments',
        data: {'bookingId': bookingId, 'method': method},
      );
      if (response.statusCode == 201) {
        final payment = PaymentModel.fromJson(
          _responseMap(response.data, 'Failed to create payment'),
        );
        await _invalidateBookingCaches(payment.bookingId);
        return payment;
      }
      throw ServerException(
        message: 'Failed to create payment',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw ServerException.fromDioException(e);
    }
  }

  @override
  Future<PaymentModel?> getPaymentByBookingId(String bookingId) async {
    try {
      final response = await _dioClient.get(
        '/payments/by-booking',
        queryParameters: {'bookingId': bookingId},
      );
      if (response.statusCode == 200) {
        final data = response.data;
        // Backend returns null/empty body when no payment exists yet
        // for the booking. Treat empty/whitespace strings as "no payment".
        if (data == null) return null;
        if (data is String && data.trim().isEmpty) return null;
        if (data is Map && data.isEmpty) return null;
        final payment = PaymentModel.fromJson(
          _responseMap(data, 'Failed to get payment'),
        );
        if (!payment.isPending) {
          await _invalidateBookingCaches(payment.bookingId);
        }
        return payment;
      }
      throw ServerException(
        message: 'Failed to get payment',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      // 404 means the booking exists but has no payment record yet.
      if (e.response?.statusCode == 404) return null;
      throw ServerException.fromDioException(e);
    }
  }

  @override
  Future<PaymentModel> getPaymentById(String paymentId) async {
    try {
      final response = await _dioClient.get('/payments/$paymentId');
      if (response.statusCode == 200) {
        return PaymentModel.fromJson(
          _responseMap(response.data, 'Payment not found'),
        );
      }
      throw ServerException(
        message: 'Payment not found',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw ServerException.fromDioException(e);
    }
  }

  @override
  Future<PaymentModel> simulateSuccess(String paymentId) async {
    try {
      final response = await _dioClient.post(
        '/payments/$paymentId/simulate-success',
      );
      if (response.statusCode == 200) {
        final payment = PaymentModel.fromJson(
          _responseMap(response.data, 'Failed to simulate payment'),
        );
        await _invalidateBookingCaches(payment.bookingId);
        return payment;
      }
      throw ServerException(
        message: 'Failed to simulate payment',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw ServerException.fromDioException(e);
    }
  }

  @override
  Future<Map<String, String>> initiatePayOS(String paymentId) async {
    try {
      final response = await _dioClient.post(
        '/payments/$paymentId/initiate-payos',
      );
      if (response.statusCode == 200) {
        final data = _responseMap(response.data, 'Failed to initiate PayOS');
        return {
          'checkoutUrl': data['checkoutUrl'] as String? ?? '',
          'qrCode': data['qrCode'] as String? ?? '',
        };
      }
      throw ServerException(
        message: 'Failed to initiate PayOS',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw ServerException.fromDioException(e);
    }
  }

  @override
  Future<Map<String, String>> initiateMoMo(String paymentId) async {
    try {
      final response = await _dioClient.post(
        '/payments/$paymentId/initiate-momo',
      );
      if (response.statusCode == 200) {
        final data = _responseMap(response.data, 'Failed to initiate MoMo');
        return {
          'paymentUrl': data['paymentUrl'] as String? ?? '',
          'deeplink': data['deeplink'] as String? ?? '',
        };
      }
      throw ServerException(
        message: 'Failed to initiate MoMo',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw ServerException.fromDioException(e);
    }
  }

  @override
  Future<PaymentModel> refund(String paymentId, String otp) async {
    try {
      final response = await _dioClient.post(
        '/payments/$paymentId/refund',
        data: {'otp': otp},
      );
      if (response.statusCode == 200) {
        final payment = PaymentModel.fromJson(
          _responseMap(response.data, 'Failed to refund payment'),
        );
        await _invalidateBookingCaches(payment.bookingId);
        return payment;
      }
      throw ServerException(
        message: 'Failed to refund payment',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw ServerException.fromDioException(e);
    }
  }

  @override
  Future<OwnerEarningsEntity> getOwnerEarnings() async {
    try {
      final response = await _dioClient.get('/payments/owner-earnings');
      if (response.statusCode == 200) {
        return OwnerEarningsEntity.fromJson(
          _responseMap(response.data, 'Failed to get earnings'),
        );
      }
      throw ServerException(
        message: 'Failed to get earnings',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      final exception = ServerException.fromDioException(e);
      if (exception.statusCode == 404 &&
          exception.message.toLowerCase().contains('payment not found')) {
        return const OwnerEarningsEntity.empty();
      }
      throw exception;
    }
  }

  Map<String, dynamic> _responseMap(dynamic data, String fallbackMessage) {
    if (data is Map<String, dynamic>) {
      return data;
    }

    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }

    if (data is String) {
      final message = data.trim().isEmpty ? fallbackMessage : data;
      throw ServerException(message: message);
    }

    throw ServerException(message: fallbackMessage);
  }

  Future<void> _invalidateBookingCaches(String bookingId) async {
    await _cache.delete('bookings.detail:$bookingId');
    await _cache.deleteByPrefix('bookings.renter:');
    await _cache.delete('bookings.upcoming');
    await _cache.delete('bookings.history');
    await _cache.deleteByPrefix('bookings.owner:');
    await _cache.delete('bookings.owner.pending');
  }
}
