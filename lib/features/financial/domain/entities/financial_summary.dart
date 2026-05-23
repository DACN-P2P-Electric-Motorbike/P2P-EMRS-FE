import 'package:equatable/equatable.dart';

enum DepositLedgerStatus {
  notHeld,
  held,
  pendingCharges,
  partiallyCaptured,
  captured,
  releasePending,
  released,
  disputed,
  refunded;

  static DepositLedgerStatus fromString(String value) {
    switch (value.toUpperCase()) {
      case 'HELD':
        return DepositLedgerStatus.held;
      case 'PENDING_CHARGES':
        return DepositLedgerStatus.pendingCharges;
      case 'PARTIALLY_CAPTURED':
        return DepositLedgerStatus.partiallyCaptured;
      case 'CAPTURED':
        return DepositLedgerStatus.captured;
      case 'RELEASE_PENDING':
        return DepositLedgerStatus.releasePending;
      case 'RELEASED':
        return DepositLedgerStatus.released;
      case 'DISPUTED':
        return DepositLedgerStatus.disputed;
      case 'REFUNDED':
        return DepositLedgerStatus.refunded;
      case 'NOT_HELD':
      default:
        return DepositLedgerStatus.notHeld;
    }
  }

  String get displayText {
    switch (this) {
      case DepositLedgerStatus.notHeld:
        return 'Chưa giữ cọc';
      case DepositLedgerStatus.held:
        return 'Đang giữ cọc';
      case DepositLedgerStatus.pendingCharges:
        return 'Có phí chờ xử lý';
      case DepositLedgerStatus.partiallyCaptured:
        return 'Đã khấu trừ một phần';
      case DepositLedgerStatus.captured:
        return 'Đã khấu trừ';
      case DepositLedgerStatus.releasePending:
        return 'Chờ hoàn cọc';
      case DepositLedgerStatus.released:
        return 'Đã hoàn cọc';
      case DepositLedgerStatus.disputed:
        return 'Đang tranh chấp';
      case DepositLedgerStatus.refunded:
        return 'Đã hoàn tiền';
    }
  }
}

enum PostTripChargeType {
  lateReturn,
  excessDistance,
  lowBattery,
  cleaning,
  damage,
  roadsideAssistance,
  other;

  static PostTripChargeType fromString(String value) {
    switch (value.toUpperCase()) {
      case 'LATE_RETURN':
        return PostTripChargeType.lateReturn;
      case 'EXCESS_DISTANCE':
        return PostTripChargeType.excessDistance;
      case 'LOW_BATTERY':
        return PostTripChargeType.lowBattery;
      case 'CLEANING':
        return PostTripChargeType.cleaning;
      case 'DAMAGE':
        return PostTripChargeType.damage;
      case 'ROADSIDE_ASSISTANCE':
        return PostTripChargeType.roadsideAssistance;
      case 'OTHER':
      default:
        return PostTripChargeType.other;
    }
  }

  String get displayText {
    switch (this) {
      case PostTripChargeType.lateReturn:
        return 'Trả xe trễ';
      case PostTripChargeType.excessDistance:
        return 'Vượt giới hạn km';
      case PostTripChargeType.lowBattery:
        return 'Pin thấp khi trả xe';
      case PostTripChargeType.cleaning:
        return 'Vệ sinh';
      case PostTripChargeType.damage:
        return 'Hư hỏng';
      case PostTripChargeType.roadsideAssistance:
        return 'Hỗ trợ sự cố';
      case PostTripChargeType.other:
        return 'Phí khác';
    }
  }
}

enum PostTripChargeStatus {
  pendingReview,
  approved,
  waived,
  disputed,
  deductedFromDeposit,
  paid,
  cancelled;

  static PostTripChargeStatus fromString(String value) {
    switch (value.toUpperCase()) {
      case 'APPROVED':
        return PostTripChargeStatus.approved;
      case 'WAIVED':
        return PostTripChargeStatus.waived;
      case 'DISPUTED':
        return PostTripChargeStatus.disputed;
      case 'DEDUCTED_FROM_DEPOSIT':
        return PostTripChargeStatus.deductedFromDeposit;
      case 'PAID':
        return PostTripChargeStatus.paid;
      case 'CANCELLED':
        return PostTripChargeStatus.cancelled;
      case 'PENDING_REVIEW':
      default:
        return PostTripChargeStatus.pendingReview;
    }
  }

  String get displayText {
    switch (this) {
      case PostTripChargeStatus.pendingReview:
        return 'Chờ duyệt';
      case PostTripChargeStatus.approved:
        return 'Đã duyệt';
      case PostTripChargeStatus.waived:
        return 'Đã miễn';
      case PostTripChargeStatus.disputed:
        return 'Đang tranh chấp';
      case PostTripChargeStatus.deductedFromDeposit:
        return 'Đã trừ cọc';
      case PostTripChargeStatus.paid:
        return 'Đã thanh toán';
      case PostTripChargeStatus.cancelled:
        return 'Đã hủy';
    }
  }
}

enum PostTripChargeSource {
  system,
  owner,
  admin;

  static PostTripChargeSource fromString(String value) {
    switch (value.toUpperCase()) {
      case 'OWNER':
        return PostTripChargeSource.owner;
      case 'ADMIN':
        return PostTripChargeSource.admin;
      case 'SYSTEM':
      default:
        return PostTripChargeSource.system;
    }
  }
}

class DepositLedgerEntity extends Equatable {
  final String id;
  final String bookingId;
  final String? paymentId;
  final DepositLedgerStatus status;
  final double heldAmount;
  final double pendingChargeAmount;
  final double capturedAmount;
  final double releasedAmount;
  final double refundedAmount;
  final String? notes;
  final DateTime? heldAt;
  final DateTime? releaseDueAt;
  final DateTime? releasedAt;
  final DateTime? disputedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DepositLedgerEntity({
    required this.id,
    required this.bookingId,
    this.paymentId,
    required this.status,
    required this.heldAmount,
    required this.pendingChargeAmount,
    required this.capturedAmount,
    required this.releasedAmount,
    required this.refundedAmount,
    this.notes,
    this.heldAt,
    this.releaseDueAt,
    this.releasedAt,
    this.disputedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get hasActiveHold =>
      status == DepositLedgerStatus.held ||
      status == DepositLedgerStatus.pendingCharges ||
      status == DepositLedgerStatus.partiallyCaptured ||
      status == DepositLedgerStatus.releasePending ||
      status == DepositLedgerStatus.disputed;

  @override
  List<Object?> get props => [
    id,
    bookingId,
    paymentId,
    status,
    heldAmount,
    pendingChargeAmount,
    capturedAmount,
    releasedAmount,
    refundedAmount,
    notes,
    heldAt,
    releaseDueAt,
    releasedAt,
    disputedAt,
    createdAt,
    updatedAt,
  ];
}

class PostTripChargeEntity extends Equatable {
  final String id;
  final String bookingId;
  final String? tripId;
  final PostTripChargeType type;
  final PostTripChargeStatus status;
  final PostTripChargeSource source;
  final double amount;
  final double? quantity;
  final double? unitPrice;
  final String description;
  final String? reviewedBy;
  final DateTime? reviewedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PostTripChargeEntity({
    required this.id,
    required this.bookingId,
    this.tripId,
    required this.type,
    required this.status,
    required this.source,
    required this.amount,
    this.quantity,
    this.unitPrice,
    required this.description,
    this.reviewedBy,
    this.reviewedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    bookingId,
    tripId,
    type,
    status,
    source,
    amount,
    quantity,
    unitPrice,
    description,
    reviewedBy,
    reviewedAt,
    createdAt,
    updatedAt,
  ];
}

class FinancialSummaryEntity extends Equatable {
  final String bookingId;
  final DepositLedgerEntity? deposit;
  final List<PostTripChargeEntity> charges;
  final double totalPendingCharges;
  final double totalApprovedCharges;
  final double totalCapturedCharges;
  final double releasableDeposit;

  const FinancialSummaryEntity({
    required this.bookingId,
    this.deposit,
    required this.charges,
    required this.totalPendingCharges,
    required this.totalApprovedCharges,
    required this.totalCapturedCharges,
    required this.releasableDeposit,
  });

  bool get hasFinancialActivity =>
      deposit != null ||
      charges.isNotEmpty ||
      totalPendingCharges > 0 ||
      totalApprovedCharges > 0 ||
      totalCapturedCharges > 0;

  @override
  List<Object?> get props => [
    bookingId,
    deposit,
    charges,
    totalPendingCharges,
    totalApprovedCharges,
    totalCapturedCharges,
    releasableDeposit,
  ];
}
