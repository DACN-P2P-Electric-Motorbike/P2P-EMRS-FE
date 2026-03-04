import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/payment_entity.dart';
import '../repositories/payment_repository.dart';

class CreatePaymentParams {
  final String bookingId;
  final PaymentMethod method;

  const CreatePaymentParams({required this.bookingId, required this.method});
}

class CreatePaymentUseCase implements UseCase<PaymentEntity, CreatePaymentParams> {
  final PaymentRepository repository;
  CreatePaymentUseCase(this.repository);

  @override
  Future<Either<Failure, PaymentEntity>> call(CreatePaymentParams params) {
    return repository.createPayment(
      bookingId: params.bookingId,
      method: params.method,
    );
  }
}

class GetPaymentByBookingParams {
  final String bookingId;
  const GetPaymentByBookingParams(this.bookingId);
}

class GetPaymentByBookingUseCase
    implements UseCase<PaymentEntity?, GetPaymentByBookingParams> {
  final PaymentRepository repository;
  GetPaymentByBookingUseCase(this.repository);

  @override
  Future<Either<Failure, PaymentEntity?>> call(
    GetPaymentByBookingParams params,
  ) {
    return repository.getPaymentByBookingId(params.bookingId);
  }
}

class SimulatePaymentSuccessParams {
  final String paymentId;
  const SimulatePaymentSuccessParams(this.paymentId);
}

class SimulatePaymentSuccessUseCase
    implements UseCase<PaymentEntity, SimulatePaymentSuccessParams> {
  final PaymentRepository repository;
  SimulatePaymentSuccessUseCase(this.repository);

  @override
  Future<Either<Failure, PaymentEntity>> call(
    SimulatePaymentSuccessParams params,
  ) {
    return repository.simulateSuccess(params.paymentId);
  }
}

class InitiatePayOSParams {
  final String paymentId;
  const InitiatePayOSParams(this.paymentId);
}

class InitiatePayOSUseCase
    implements UseCase<Map<String, String>, InitiatePayOSParams> {
  final PaymentRepository repository;
  InitiatePayOSUseCase(this.repository);

  @override
  Future<Either<Failure, Map<String, String>>> call(InitiatePayOSParams params) {
    return repository.initiatePayOS(params.paymentId);
  }
}

class InitiateMoMoParams {
  final String paymentId;
  const InitiateMoMoParams(this.paymentId);
}

class InitiateMoMoUseCase
    implements UseCase<Map<String, String>, InitiateMoMoParams> {
  final PaymentRepository repository;
  InitiateMoMoUseCase(this.repository);

  @override
  Future<Either<Failure, Map<String, String>>> call(InitiateMoMoParams params) {
    return repository.initiateMoMo(params.paymentId);
  }
}
