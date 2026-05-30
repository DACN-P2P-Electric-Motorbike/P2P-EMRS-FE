import 'package:equatable/equatable.dart';

/// Booking status enum matching backend
enum BookingStatus {
  PENDING,
  CONFIRMED,
  ONGOING,
  COMPLETED,
  CANCELLED,
  REJECTED;

  static BookingStatus fromString(String value) {
    return BookingStatus.values.firstWhere(
      (e) => e.name == value.toUpperCase(),
      orElse: () => BookingStatus.PENDING,
    );
  }
}

/// Refund summary recorded when a paid booking is cancelled, so the renter can
/// see how much money is refunded (rental/deposit split + total) instead of
/// only the cancellation reason.
class BookingRefundInfo extends Equatable {
  final String refundType;
  final double rentalRefundRate;
  final double refundableRentalAmount;
  final double refundableProtectionAmount;
  final double refundablePrepaidChargingAmount;
  final double refundableRoadsideSupportAmount;
  final double refundableDepositAmount;
  final double refundAmount;
  final double paidAmount;
  final double forfeitedAmount;
  final String? cancelledBy;
  final DateTime? cancelledAt;

  const BookingRefundInfo({
    this.refundType = 'none',
    this.rentalRefundRate = 0,
    this.refundableRentalAmount = 0,
    this.refundableProtectionAmount = 0,
    this.refundablePrepaidChargingAmount = 0,
    this.refundableRoadsideSupportAmount = 0,
    this.refundableDepositAmount = 0,
    this.refundAmount = 0,
    this.paidAmount = 0,
    this.forfeitedAmount = 0,
    this.cancelledBy,
    this.cancelledAt,
  });

  @override
  List<Object?> get props => [
    refundType,
    rentalRefundRate,
    refundableRentalAmount,
    refundableProtectionAmount,
    refundablePrepaidChargingAmount,
    refundableRoadsideSupportAmount,
    refundableDepositAmount,
    refundAmount,
    paidAmount,
    forfeitedAmount,
    cancelledBy,
    cancelledAt,
  ];
}

/// Booking entity - pure Dart object without any JSON logic
class BookingEntity extends Equatable {
  final String id;
  final String renterId;
  final String ownerId;
  final String vehicleId;
  final BookingStatus status;
  final DateTime startTime;
  final DateTime endTime;
  final double totalPrice;
  final double deposit;
  final String protectionPlan;
  final double protectionFee;
  final double protectionDeductible;
  final double protectionCoverageLimit;
  final bool prepaidCharging;
  final double prepaidChargingFee;
  final int prepaidChargingCreditPercent;
  final bool roadsideSupport;
  final double roadsideSupportFee;
  final double roadsideSupportCreditAmount;
  final String cancellationPolicy;
  final String? notes;
  final String? cancellationReason;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? confirmedAt;
  final DateTime? cancelledAt;
  final String? vehicleName;
  final int? vehicleBatteryLevel;
  final String? paymentStatus;
  final BookingRefundInfo? refundInfo;

  const BookingEntity({
    required this.id,
    required this.renterId,
    required this.ownerId,
    required this.vehicleId,
    required this.status,
    required this.startTime,
    required this.endTime,
    required this.totalPrice,
    required this.deposit,
    this.protectionPlan = 'STANDARD',
    this.protectionFee = 0,
    this.protectionDeductible = 1500000,
    this.protectionCoverageLimit = 15000000,
    this.prepaidCharging = false,
    this.prepaidChargingFee = 0,
    this.prepaidChargingCreditPercent = 0,
    this.roadsideSupport = false,
    this.roadsideSupportFee = 0,
    this.roadsideSupportCreditAmount = 0,
    this.cancellationPolicy = 'FLEXIBLE',
    this.notes,
    this.cancellationReason,
    required this.createdAt,
    required this.updatedAt,
    this.confirmedAt,
    this.cancelledAt,
    this.vehicleName,
    this.vehicleBatteryLevel,
    this.paymentStatus,
    this.refundInfo,
  });

  /// Check if booking is pending
  bool get isPending => status == BookingStatus.PENDING;

  /// Check if booking is confirmed
  bool get isConfirmed => status == BookingStatus.CONFIRMED;

  /// Check if booking has a completed payment
  bool get isPaymentCompleted => paymentStatus?.toUpperCase() == 'COMPLETED';

  /// Check if booking still needs payment before it can start
  bool get needsPaymentBeforeStart => isConfirmed && !isPaymentCompleted;

  /// Check if the current time is inside the pickup window.
  bool get isWithinStartWindow {
    final now = DateTime.now();
    final earliestStart = startTime.subtract(const Duration(minutes: 15));
    final latestStart = startTime.add(const Duration(hours: 2));
    return !now.isBefore(earliestStart) && !now.isAfter(latestStart);
  }

  /// Check if a paid confirmed booking can be started from the client.
  bool get canStartTripNow =>
      isConfirmed && isPaymentCompleted && isWithinStartWindow;

  /// Check if booking is ongoing
  bool get isOngoing => status == BookingStatus.ONGOING;

  /// Check if booking is completed
  bool get isCompleted => status == BookingStatus.COMPLETED;

  /// Check if booking is cancelled
  bool get isCancelled => status == BookingStatus.CANCELLED;

  /// Check if booking is rejected
  bool get isRejected => status == BookingStatus.REJECTED;

  /// Check if booking can be cancelled
  bool get canBeCancelled => isPending || isConfirmed;

  /// Get duration in whole hours.
  int get durationInHours {
    return endTime.difference(startTime).inHours;
  }

  /// Get a human-readable duration without rounding sub-hour bookings to zero.
  String get durationDisplayText {
    final duration = endTime.difference(startTime);
    final totalMinutes = duration.inMinutes;

    if (totalMinutes <= 0) {
      return '0 phút';
    }

    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;

    if (hours == 0) {
      return '$minutes phút';
    }
    if (minutes == 0) {
      return '$hours giờ';
    }
    return '$hours giờ $minutes phút';
  }

  /// Get status display text
  String get statusDisplayText {
    switch (status) {
      case BookingStatus.PENDING:
        return 'Chờ xác nhận';
      case BookingStatus.CONFIRMED:
        return 'Đã xác nhận';
      case BookingStatus.ONGOING:
        return 'Đang thuê';
      case BookingStatus.COMPLETED:
        return 'Hoàn thành';
      case BookingStatus.CANCELLED:
        return 'Đã hủy';
      case BookingStatus.REJECTED:
        return 'Bị từ chối';
    }
  }

  @override
  List<Object?> get props => [
    id,
    renterId,
    ownerId,
    vehicleId,
    status,
    startTime,
    endTime,
    totalPrice,
    deposit,
    protectionPlan,
    protectionFee,
    protectionDeductible,
    protectionCoverageLimit,
    prepaidCharging,
    prepaidChargingFee,
    prepaidChargingCreditPercent,
    roadsideSupport,
    roadsideSupportFee,
    roadsideSupportCreditAmount,
    cancellationPolicy,
    notes,
    cancellationReason,
    createdAt,
    updatedAt,
    confirmedAt,
    cancelledAt,
    vehicleName,
    vehicleBatteryLevel,
    paymentStatus,
    refundInfo,
  ];

  BookingEntity copyWith({
    String? id,
    String? renterId,
    String? ownerId,
    String? vehicleId,
    BookingStatus? status,
    DateTime? startTime,
    DateTime? endTime,
    double? totalPrice,
    double? deposit,
    String? protectionPlan,
    double? protectionFee,
    double? protectionDeductible,
    double? protectionCoverageLimit,
    bool? prepaidCharging,
    double? prepaidChargingFee,
    int? prepaidChargingCreditPercent,
    bool? roadsideSupport,
    double? roadsideSupportFee,
    double? roadsideSupportCreditAmount,
    String? cancellationPolicy,
    String? notes,
    String? cancellationReason,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? confirmedAt,
    DateTime? cancelledAt,
    String? vehicleName,
    int? vehicleBatteryLevel,
    String? paymentStatus,
    BookingRefundInfo? refundInfo,
  }) {
    return BookingEntity(
      id: id ?? this.id,
      renterId: renterId ?? this.renterId,
      ownerId: ownerId ?? this.ownerId,
      vehicleId: vehicleId ?? this.vehicleId,
      status: status ?? this.status,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      totalPrice: totalPrice ?? this.totalPrice,
      deposit: deposit ?? this.deposit,
      protectionPlan: protectionPlan ?? this.protectionPlan,
      protectionFee: protectionFee ?? this.protectionFee,
      protectionDeductible: protectionDeductible ?? this.protectionDeductible,
      protectionCoverageLimit:
          protectionCoverageLimit ?? this.protectionCoverageLimit,
      prepaidCharging: prepaidCharging ?? this.prepaidCharging,
      prepaidChargingFee: prepaidChargingFee ?? this.prepaidChargingFee,
      prepaidChargingCreditPercent:
          prepaidChargingCreditPercent ?? this.prepaidChargingCreditPercent,
      roadsideSupport: roadsideSupport ?? this.roadsideSupport,
      roadsideSupportFee: roadsideSupportFee ?? this.roadsideSupportFee,
      roadsideSupportCreditAmount:
          roadsideSupportCreditAmount ?? this.roadsideSupportCreditAmount,
      cancellationPolicy: cancellationPolicy ?? this.cancellationPolicy,
      notes: notes ?? this.notes,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      confirmedAt: confirmedAt ?? this.confirmedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      vehicleName: vehicleName ?? this.vehicleName,
      vehicleBatteryLevel: vehicleBatteryLevel ?? this.vehicleBatteryLevel,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      refundInfo: refundInfo ?? this.refundInfo,
    );
  }
}
