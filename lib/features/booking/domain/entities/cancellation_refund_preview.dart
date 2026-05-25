import 'package:equatable/equatable.dart';

class CancellationRefundPreview extends Equatable {
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

  const CancellationRefundPreview({
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

  String get policyDisplayText {
    switch (policyCode) {
      case 'OWNER_FULL_REFUND':
        return 'Chủ xe hủy: hoàn toàn bộ';
      case 'RENTER_EARLY_FULL_REFUND':
        return 'Hủy sớm: hoàn toàn bộ';
      case 'RENTER_STANDARD_PARTIAL_REFUND':
        return 'Hoàn 50% tiền thuê';
      case 'RENTER_LATE_DEPOSIT_ONLY':
        return 'Hoàn tiền cọc';
      default:
        return 'Không thể hủy';
    }
  }

  @override
  List<Object?> get props => [
    bookingId,
    cancelledBy,
    cancellable,
    hoursUntilStart,
    policyCode,
    rentalRefundRate,
    trustPenalty,
    rentalAmount,
    protectionAmount,
    prepaidChargingAmount,
    depositAmount,
    paidAmount,
    refundableRentalAmount,
    refundableProtectionAmount,
    refundablePrepaidChargingAmount,
    refundableDepositAmount,
    refundAmount,
    forfeitedRentalAmount,
    forfeitedProtectionAmount,
    forfeitedPrepaidChargingAmount,
    forfeitedDepositAmount,
    forfeitedAmount,
    isPaid,
    paymentStatus,
    refundType,
  ];
}
