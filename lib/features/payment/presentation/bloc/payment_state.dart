import 'package:equatable/equatable.dart';
import '../../domain/entities/payment_entity.dart';
import '../../domain/entities/owner_earnings_entity.dart';

abstract class PaymentState extends Equatable {
  const PaymentState();

  @override
  List<Object?> get props => [];
}

class PaymentInitial extends PaymentState {
  const PaymentInitial();
}

class PaymentLoading extends PaymentState {
  const PaymentLoading();
}

class PaymentLoaded extends PaymentState {
  final PaymentEntity payment;
  const PaymentLoaded(this.payment);

  @override
  List<Object?> get props => [payment];
}

class NoPaymentFound extends PaymentState {
  const NoPaymentFound();
}

class PaymentCreated extends PaymentState {
  final PaymentEntity payment;
  const PaymentCreated(this.payment);

  @override
  List<Object?> get props => [payment];
}

class PaymentSuccess extends PaymentState {
  final PaymentEntity payment;
  final String message;

  const PaymentSuccess(this.payment, this.message);

  @override
  List<Object?> get props => [payment, message];
}

class PaymentUrlGenerated extends PaymentState {
  final String paymentUrl;
  final String? deeplink;
  final String? qrCode;

  const PaymentUrlGenerated({
    required this.paymentUrl,
    this.deeplink,
    this.qrCode,
  });

  @override
  List<Object?> get props => [paymentUrl, deeplink, qrCode];
}

class PaymentFailure extends PaymentState {
  final String message;
  const PaymentFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class PaymentRefunded extends PaymentState {
  final PaymentEntity payment;
  const PaymentRefunded(this.payment);

  @override
  List<Object?> get props => [payment];
}

class OwnerEarningsLoaded extends PaymentState {
  final OwnerEarningsEntity earnings;
  const OwnerEarningsLoaded(this.earnings);

  @override
  List<Object?> get props => [earnings];
}
