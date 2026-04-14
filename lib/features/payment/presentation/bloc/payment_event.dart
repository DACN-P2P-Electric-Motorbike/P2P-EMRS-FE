import 'package:equatable/equatable.dart';
import '../../domain/entities/payment_entity.dart';

abstract class PaymentEvent extends Equatable {
  const PaymentEvent();

  @override
  List<Object?> get props => [];
}

class CreatePaymentEvent extends PaymentEvent {
  final String bookingId;
  final PaymentMethod method;

  const CreatePaymentEvent({required this.bookingId, required this.method});

  @override
  List<Object?> get props => [bookingId, method];
}

class LoadPaymentByBookingEvent extends PaymentEvent {
  final String bookingId;

  const LoadPaymentByBookingEvent(this.bookingId);

  @override
  List<Object?> get props => [bookingId];
}

class SimulatePaymentSuccessEvent extends PaymentEvent {
  final String paymentId;

  const SimulatePaymentSuccessEvent(this.paymentId);

  @override
  List<Object?> get props => [paymentId];
}

class InitiatePayOSEvent extends PaymentEvent {
  final String paymentId;

  const InitiatePayOSEvent(this.paymentId);

  @override
  List<Object?> get props => [paymentId];
}

class InitiateMoMoEvent extends PaymentEvent {
  final String paymentId;

  const InitiateMoMoEvent(this.paymentId);

  @override
  List<Object?> get props => [paymentId];
}

class GetPaymentByIdEvent extends PaymentEvent {
  final String paymentId;

  const GetPaymentByIdEvent(this.paymentId);

  @override
  List<Object?> get props => [paymentId];
}

class RefundPaymentEvent extends PaymentEvent {
  final String paymentId;

  const RefundPaymentEvent(this.paymentId);

  @override
  List<Object?> get props => [paymentId];
}

class ResetPaymentStateEvent extends PaymentEvent {
  const ResetPaymentStateEvent();
}

class LoadOwnerEarningsEvent extends PaymentEvent {
  const LoadOwnerEarningsEvent();
}
