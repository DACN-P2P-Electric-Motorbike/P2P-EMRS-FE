import '../../domain/entities/payment_entity.dart';

class PaymentModel extends PaymentEntity {
  const PaymentModel({
    required super.id,
    required super.bookingId,
    required super.payerId,
    required super.receiverId,
    required super.amount,
    required super.platformFee,
    required super.ownerAmount,
    required super.method,
    required super.status,
    super.transactionId,
    required super.createdAt,
    required super.updatedAt,
    super.paidAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    PaymentStatus parseStatus(String? value) {
      switch ((value ?? '').toUpperCase()) {
        case 'PROCESSING':
          return PaymentStatus.processing;
        case 'COMPLETED':
          return PaymentStatus.completed;
        case 'FAILED':
          return PaymentStatus.failed;
        case 'REFUNDED':
          return PaymentStatus.refunded;
        default:
          return PaymentStatus.pending;
      }
    }

    PaymentMethod parseMethod(String? value) {
      switch ((value ?? '').toUpperCase()) {
        case 'PAYOS':
          return PaymentMethod.payos;
        case 'MOMO':
          return PaymentMethod.momo;
        case 'CREDIT_CARD':
          return PaymentMethod.creditCard;
        default:
          return PaymentMethod.cash;
      }
    }

    return PaymentModel(
      id: json['id'] as String,
      bookingId: json['bookingId'] as String,
      payerId: json['payerId'] as String,
      receiverId: json['receiverId'] as String,
      amount: (json['amount'] as num).toDouble(),
      platformFee: (json['platformFee'] as num).toDouble(),
      ownerAmount: (json['ownerAmount'] as num).toDouble(),
      method: parseMethod(json['method'] as String?),
      status: parseStatus(json['status'] as String?),
      transactionId: json['transactionId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      paidAt: json['paidAt'] != null
          ? DateTime.parse(json['paidAt'] as String)
          : null,
    );
  }

  PaymentEntity toEntity() => PaymentEntity(
    id: id,
    bookingId: bookingId,
    payerId: payerId,
    receiverId: receiverId,
    amount: amount,
    platformFee: platformFee,
    ownerAmount: ownerAmount,
    method: method,
    status: status,
    transactionId: transactionId,
    createdAt: createdAt,
    updatedAt: updatedAt,
    paidAt: paidAt,
  );
}
