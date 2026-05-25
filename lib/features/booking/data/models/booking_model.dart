import '../../domain/entities/booking.dart';

/// Booking model for API responses
/// Field names must match the JSON returned by NestJS exactly
class BookingModel {
  final String id;
  final String renterId;
  final String ownerId;
  final String vehicleId;
  final String status;
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
  final String? notes;
  final String? cancellationReason;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? confirmedAt;
  final DateTime? cancelledAt;
  final String? vehicleName;
  final int? vehicleBatteryLevel;
  final String? paymentStatus;

  const BookingModel({
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
    this.notes,
    this.cancellationReason,
    required this.createdAt,
    required this.updatedAt,
    this.confirmedAt,
    this.cancelledAt,
    this.vehicleName,
    this.vehicleBatteryLevel,
    this.paymentStatus,
  });

  /// Parse from JSON response
  factory BookingModel.fromJson(Map<String, dynamic> json) {
    final nestedPayment = json['payment'];
    final nestedPaymentStatus = nestedPayment is Map
        ? nestedPayment['status'] as String?
        : null;
    final nestedVehicle = json['vehicle'];
    final vehicleBatteryLevel = nestedVehicle is Map
        ? (nestedVehicle['batteryLevel'] as num?)?.toInt()
        : null;

    return BookingModel(
      id: json['id'] as String,
      renterId: json['renterId'] as String,
      ownerId: json['ownerId'] as String,
      vehicleId: json['vehicleId'] as String,
      status: json['status'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      totalPrice: (json['totalPrice'] as num).toDouble(),
      deposit: (json['deposit'] as num).toDouble(),
      protectionPlan: json['protectionPlan'] as String? ?? 'STANDARD',
      protectionFee: (json['protectionFee'] as num?)?.toDouble() ?? 0,
      protectionDeductible:
          (json['protectionDeductible'] as num?)?.toDouble() ?? 1500000,
      protectionCoverageLimit:
          (json['protectionCoverageLimit'] as num?)?.toDouble() ?? 15000000,
      prepaidCharging: json['prepaidCharging'] as bool? ?? false,
      prepaidChargingFee: (json['prepaidChargingFee'] as num?)?.toDouble() ?? 0,
      prepaidChargingCreditPercent:
          (json['prepaidChargingCreditPercent'] as num?)?.toInt() ?? 0,
      notes: json['notes'] as String?,
      cancellationReason: json['cancellationReason'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      confirmedAt: json['confirmedAt'] != null
          ? DateTime.parse(json['confirmedAt'] as String)
          : null,
      cancelledAt: json['cancelledAt'] != null
          ? DateTime.parse(json['cancelledAt'] as String)
          : null,
      vehicleName: nestedVehicle is Map
          ? nestedVehicle['name'] as String?
          : null,
      vehicleBatteryLevel: vehicleBatteryLevel,
      paymentStatus: json['paymentStatus'] as String? ?? nestedPaymentStatus,
    );
  }

  /// Convert to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'renterId': renterId,
      'ownerId': ownerId,
      'vehicleId': vehicleId,
      'status': status,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'totalPrice': totalPrice,
      'deposit': deposit,
      'protectionPlan': protectionPlan,
      'protectionFee': protectionFee,
      'protectionDeductible': protectionDeductible,
      'protectionCoverageLimit': protectionCoverageLimit,
      'prepaidCharging': prepaidCharging,
      'prepaidChargingFee': prepaidChargingFee,
      'prepaidChargingCreditPercent': prepaidChargingCreditPercent,
      'notes': notes,
      'cancellationReason': cancellationReason,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'confirmedAt': confirmedAt?.toIso8601String(),
      'cancelledAt': cancelledAt?.toIso8601String(),
      if (vehicleName != null || vehicleBatteryLevel != null)
        'vehicle': {
          if (vehicleName != null) 'name': vehicleName,
          if (vehicleBatteryLevel != null) 'batteryLevel': vehicleBatteryLevel,
        },
      'paymentStatus': paymentStatus,
    };
  }

  /// Convert to domain entity
  BookingEntity toEntity() {
    return BookingEntity(
      id: id,
      renterId: renterId,
      ownerId: ownerId,
      vehicleId: vehicleId,
      status: BookingStatus.fromString(status),
      startTime: startTime,
      endTime: endTime,
      totalPrice: totalPrice,
      deposit: deposit,
      protectionPlan: protectionPlan,
      protectionFee: protectionFee,
      protectionDeductible: protectionDeductible,
      protectionCoverageLimit: protectionCoverageLimit,
      prepaidCharging: prepaidCharging,
      prepaidChargingFee: prepaidChargingFee,
      prepaidChargingCreditPercent: prepaidChargingCreditPercent,
      notes: notes,
      cancellationReason: cancellationReason,
      createdAt: createdAt,
      updatedAt: updatedAt,
      confirmedAt: confirmedAt,
      cancelledAt: cancelledAt,
      vehicleName: vehicleName,
      vehicleBatteryLevel: vehicleBatteryLevel,
      paymentStatus: paymentStatus,
    );
  }
}
