import '../../domain/entities/cancellation_refund_preview.dart';

class CancellationRefundPreviewModel {
  final String bookingId;
  final String cancelledBy;
  final bool cancellable;
  final double hoursUntilStart;
  final String policyCode;
  final double rentalRefundRate;
  final double trustPenalty;
  final double rentalAmount;
  final double protectionAmount;
  final double prepaidChargingAmount;
  final double depositAmount;
  final double paidAmount;
  final double refundableRentalAmount;
  final double refundableProtectionAmount;
  final double refundablePrepaidChargingAmount;
  final double refundableDepositAmount;
  final double refundAmount;
  final double forfeitedRentalAmount;
  final double forfeitedProtectionAmount;
  final double forfeitedPrepaidChargingAmount;
  final double forfeitedDepositAmount;
  final double forfeitedAmount;
  final bool isPaid;
  final String? paymentStatus;
  final String refundType;

  const CancellationRefundPreviewModel({
    required this.bookingId,
    required this.cancelledBy,
    required this.cancellable,
    required this.hoursUntilStart,
    required this.policyCode,
    required this.rentalRefundRate,
    required this.trustPenalty,
    required this.rentalAmount,
    this.protectionAmount = 0,
    this.prepaidChargingAmount = 0,
    required this.depositAmount,
    required this.paidAmount,
    required this.refundableRentalAmount,
    this.refundableProtectionAmount = 0,
    this.refundablePrepaidChargingAmount = 0,
    required this.refundableDepositAmount,
    required this.refundAmount,
    required this.forfeitedRentalAmount,
    this.forfeitedProtectionAmount = 0,
    this.forfeitedPrepaidChargingAmount = 0,
    required this.forfeitedDepositAmount,
    required this.forfeitedAmount,
    required this.isPaid,
    this.paymentStatus,
    required this.refundType,
  });

  factory CancellationRefundPreviewModel.fromJson(Map<String, dynamic> json) {
    return CancellationRefundPreviewModel(
      bookingId: json['bookingId'] as String,
      cancelledBy: json['cancelledBy'] as String? ?? 'RENTER',
      cancellable: json['cancellable'] as bool? ?? false,
      hoursUntilStart: _asDouble(json['hoursUntilStart']),
      policyCode: json['policyCode'] as String? ?? 'NOT_CANCELLABLE',
      rentalRefundRate: _asDouble(json['rentalRefundRate']),
      trustPenalty: _asDouble(json['trustPenalty']),
      rentalAmount: _asDouble(json['rentalAmount']),
      protectionAmount: _asDouble(json['protectionAmount']),
      prepaidChargingAmount: _asDouble(json['prepaidChargingAmount']),
      depositAmount: _asDouble(json['depositAmount']),
      paidAmount: _asDouble(json['paidAmount']),
      refundableRentalAmount: _asDouble(json['refundableRentalAmount']),
      refundableProtectionAmount: _asDouble(json['refundableProtectionAmount']),
      refundablePrepaidChargingAmount: _asDouble(
        json['refundablePrepaidChargingAmount'],
      ),
      refundableDepositAmount: _asDouble(json['refundableDepositAmount']),
      refundAmount: _asDouble(json['refundAmount']),
      forfeitedRentalAmount: _asDouble(json['forfeitedRentalAmount']),
      forfeitedProtectionAmount: _asDouble(json['forfeitedProtectionAmount']),
      forfeitedPrepaidChargingAmount: _asDouble(
        json['forfeitedPrepaidChargingAmount'],
      ),
      forfeitedDepositAmount: _asDouble(json['forfeitedDepositAmount']),
      forfeitedAmount: _asDouble(json['forfeitedAmount']),
      isPaid: json['isPaid'] as bool? ?? false,
      paymentStatus: json['paymentStatus'] as String?,
      refundType: json['refundType'] as String? ?? 'none',
    );
  }

  CancellationRefundPreview toEntity() {
    return CancellationRefundPreview(
      bookingId: bookingId,
      cancelledBy: cancelledBy,
      cancellable: cancellable,
      hoursUntilStart: hoursUntilStart,
      policyCode: policyCode,
      rentalRefundRate: rentalRefundRate,
      trustPenalty: trustPenalty,
      rentalAmount: rentalAmount,
      protectionAmount: protectionAmount,
      prepaidChargingAmount: prepaidChargingAmount,
      depositAmount: depositAmount,
      paidAmount: paidAmount,
      refundableRentalAmount: refundableRentalAmount,
      refundableProtectionAmount: refundableProtectionAmount,
      refundablePrepaidChargingAmount: refundablePrepaidChargingAmount,
      refundableDepositAmount: refundableDepositAmount,
      refundAmount: refundAmount,
      forfeitedRentalAmount: forfeitedRentalAmount,
      forfeitedProtectionAmount: forfeitedProtectionAmount,
      forfeitedPrepaidChargingAmount: forfeitedPrepaidChargingAmount,
      forfeitedDepositAmount: forfeitedDepositAmount,
      forfeitedAmount: forfeitedAmount,
      isPaid: isPaid,
      paymentStatus: paymentStatus,
      refundType: refundType,
    );
  }
}

double _asDouble(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0;
  return 0;
}
