import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/payment_entity.dart';

abstract class PaymentRepository {
  Future<Either<Failure, PaymentEntity>> createPayment({
    required String bookingId,
    required PaymentMethod method,
  });

  Future<Either<Failure, PaymentEntity?>> getPaymentByBookingId(
    String bookingId,
  );

  Future<Either<Failure, PaymentEntity>> getPaymentById(String paymentId);

  Future<Either<Failure, PaymentEntity>> simulateSuccess(String paymentId);

  Future<Either<Failure, Map<String, String>>> initiatePayOS(String paymentId);

  Future<Either<Failure, Map<String, String>>> initiateMoMo(String paymentId);

  Future<Either<Failure, PaymentEntity>> refund(String paymentId);
}
