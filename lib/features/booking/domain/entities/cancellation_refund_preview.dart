import 'package:equatable/equatable.dart';

class CancellationRefundPreview extends Equatable {
  final String bookingId;
  final String cancelledBy;
  final bool cancellable;
  final double hoursUntilStart;
  final String policyCode;
  final String cancellationPolicy;
  final double rentalRefundRate;
  final double trustPenalty;
  final double rentalAmount;
  final double protectionAmount;
  final double prepaidChargingAmount;
  final double roadsideSupportAmount;
  final double depositAmount;
  final double paidAmount;
  final double refundableRentalAmount;
  final double refundableProtectionAmount;
  final double refundablePrepaidChargingAmount;
  final double refundableRoadsideSupportAmount;
  final double refundableDepositAmount;
  final double refundAmount;
  final double forfeitedRentalAmount;
  final double forfeitedProtectionAmount;
  final double forfeitedPrepaidChargingAmount;
  final double forfeitedRoadsideSupportAmount;
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
    this.cancellationPolicy = 'FLEXIBLE',
    required this.rentalRefundRate,
    required this.trustPenalty,
    required this.rentalAmount,
    this.protectionAmount = 0,
    this.prepaidChargingAmount = 0,
    this.roadsideSupportAmount = 0,
    required this.depositAmount,
    required this.paidAmount,
    required this.refundableRentalAmount,
    this.refundableProtectionAmount = 0,
    this.refundablePrepaidChargingAmount = 0,
    this.refundableRoadsideSupportAmount = 0,
    required this.refundableDepositAmount,
    required this.refundAmount,
    required this.forfeitedRentalAmount,
    this.forfeitedProtectionAmount = 0,
    this.forfeitedPrepaidChargingAmount = 0,
    this.forfeitedRoadsideSupportAmount = 0,
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
      case 'RENTER_FLEXIBLE_FULL_REFUND':
        return 'Linh hoạt: hoàn toàn bộ phí thuê';
      case 'RENTER_FLEXIBLE_PARTIAL_REFUND':
        return 'Linh hoạt: hoàn 50% phí thuê';
      case 'RENTER_MODERATE_FULL_REFUND':
        return 'Trung bình: hoàn toàn bộ phí thuê';
      case 'RENTER_MODERATE_PARTIAL_REFUND':
        return 'Trung bình: hoàn 50% phí thuê';
      case 'RENTER_STRICT_PARTIAL_REFUND':
        return 'Nghiêm ngặt: hoàn 50% phí thuê';
      case 'RENTER_STRICT_NO_REFUND':
        return 'Nghiêm ngặt: không hoàn phí thuê';
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
    cancellationPolicy,
    rentalRefundRate,
    trustPenalty,
    rentalAmount,
    protectionAmount,
    prepaidChargingAmount,
    roadsideSupportAmount,
    depositAmount,
    paidAmount,
    refundableRentalAmount,
    refundableProtectionAmount,
    refundablePrepaidChargingAmount,
    refundableRoadsideSupportAmount,
    refundableDepositAmount,
    refundAmount,
    forfeitedRentalAmount,
    forfeitedProtectionAmount,
    forfeitedPrepaidChargingAmount,
    forfeitedRoadsideSupportAmount,
    forfeitedDepositAmount,
    forfeitedAmount,
    isPaid,
    paymentStatus,
    refundType,
  ];
}
