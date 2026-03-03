import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/payment_model.dart';

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

  Future<PaymentModel> refund(String paymentId);
}

class PaymentRemoteDataSourceImpl implements PaymentRemoteDataSource {
  final DioClient _dioClient;

  PaymentRemoteDataSourceImpl({required DioClient dioClient})
    : _dioClient = dioClient;

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
        return PaymentModel.fromJson(response.data as Map<String, dynamic>);
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
        if (response.data == null) return null;
        return PaymentModel.fromJson(response.data as Map<String, dynamic>);
      }
      throw ServerException(
        message: 'Failed to get payment',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw ServerException.fromDioException(e);
    }
  }

  @override
  Future<PaymentModel> getPaymentById(String paymentId) async {
    try {
      final response = await _dioClient.get('/payments/$paymentId');
      if (response.statusCode == 200) {
        return PaymentModel.fromJson(response.data as Map<String, dynamic>);
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
        return PaymentModel.fromJson(response.data as Map<String, dynamic>);
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
        final data = response.data as Map<String, dynamic>;
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
        final data = response.data as Map<String, dynamic>;
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
  Future<PaymentModel> refund(String paymentId) async {
    try {
      final response = await _dioClient.post('/payments/$paymentId/refund');
      if (response.statusCode == 200) {
        return PaymentModel.fromJson(response.data as Map<String, dynamic>);
      }
      throw ServerException(
        message: 'Failed to refund payment',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw ServerException.fromDioException(e);
    }
  }
}
