import 'package:equatable/equatable.dart';

enum PaymentStatus { pending, processing, completed, failed, refunded }

enum PaymentMethod { payos, momo, creditCard, cash }

class PaymentEntity extends Equatable {
  final String id;
  final String bookingId;
  final String payerId;
  final String receiverId;
  final double amount;
  final double platformFee;
  final double ownerAmount;
  final PaymentMethod method;
  final PaymentStatus status;
  final String? transactionId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? paidAt;

  const PaymentEntity({
    required this.id,
    required this.bookingId,
    required this.payerId,
    required this.receiverId,
    required this.amount,
    required this.platformFee,
    required this.ownerAmount,
    required this.method,
    required this.status,
    this.transactionId,
    required this.createdAt,
    required this.updatedAt,
    this.paidAt,
  });

  bool get isPending => status == PaymentStatus.pending;
  bool get isCompleted => status == PaymentStatus.completed;
  bool get isFailed => status == PaymentStatus.failed;
  bool get isRefunded => status == PaymentStatus.refunded;

  String get statusDisplayText {
    switch (status) {
      case PaymentStatus.pending:
        return 'Chờ thanh toán';
      case PaymentStatus.processing:
        return 'Đang xử lý';
      case PaymentStatus.completed:
        return 'Đã thanh toán';
      case PaymentStatus.failed:
        return 'Thanh toán thất bại';
      case PaymentStatus.refunded:
        return 'Đã hoàn tiền';
    }
  }

  String get methodDisplayText {
    switch (method) {
      case PaymentMethod.payos:
        return 'PayOS';
      case PaymentMethod.momo:
        return 'MoMo';
      case PaymentMethod.creditCard:
        return 'Thẻ tín dụng';
      case PaymentMethod.cash:
        return 'Tiền mặt';
    }
  }

  @override
  List<Object?> get props => [
    id,
    bookingId,
    payerId,
    receiverId,
    amount,
    platformFee,
    ownerAmount,
    method,
    status,
    transactionId,
    createdAt,
    updatedAt,
    paidAt,
  ];
}
