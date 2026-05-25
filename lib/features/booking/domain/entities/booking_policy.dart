import 'package:equatable/equatable.dart';

class BookingPolicy extends Equatable {
  final String defaultProtectionPlan;
  final List<ProtectionPlanPolicy> protectionPlans;
  final PrepaidChargingPolicy prepaidCharging;
  final RoadsideSupportPolicy roadsideSupport;

  const BookingPolicy({
    required this.defaultProtectionPlan,
    required this.protectionPlans,
    required this.prepaidCharging,
    required this.roadsideSupport,
  });

  static const fallback = BookingPolicy(
    defaultProtectionPlan: 'STANDARD',
    protectionPlans: [
      ProtectionPlanPolicy(
        protectionPlan: 'BASIC',
        feeRate: 0,
        deductible: 3000000,
        coverageLimit: 5000000,
        isDefault: false,
      ),
      ProtectionPlanPolicy(
        protectionPlan: 'STANDARD',
        feeRate: 0.05,
        deductible: 1500000,
        coverageLimit: 15000000,
        isDefault: true,
      ),
      ProtectionPlanPolicy(
        protectionPlan: 'PREMIUM',
        feeRate: 0.1,
        deductible: 500000,
        coverageLimit: 30000000,
        isDefault: false,
      ),
    ],
    prepaidCharging: PrepaidChargingPolicy(
      fee: 50000,
      creditPercent: 10,
      requiresBatteryReturnMinimum: true,
    ),
    roadsideSupport: RoadsideSupportPolicy(fee: 30000, creditAmount: 200000),
  );

  @override
  List<Object?> get props => [
    defaultProtectionPlan,
    protectionPlans,
    prepaidCharging,
    roadsideSupport,
  ];
}

class ProtectionPlanPolicy extends Equatable {
  final String protectionPlan;
  final double feeRate;
  final double deductible;
  final double coverageLimit;
  final bool isDefault;

  const ProtectionPlanPolicy({
    required this.protectionPlan,
    required this.feeRate,
    required this.deductible,
    required this.coverageLimit,
    required this.isDefault,
  });

  @override
  List<Object?> get props => [
    protectionPlan,
    feeRate,
    deductible,
    coverageLimit,
    isDefault,
  ];
}

class PrepaidChargingPolicy extends Equatable {
  final double fee;
  final int creditPercent;
  final bool requiresBatteryReturnMinimum;

  const PrepaidChargingPolicy({
    required this.fee,
    required this.creditPercent,
    required this.requiresBatteryReturnMinimum,
  });

  @override
  List<Object?> get props => [fee, creditPercent, requiresBatteryReturnMinimum];
}

class RoadsideSupportPolicy extends Equatable {
  final double fee;
  final double creditAmount;

  const RoadsideSupportPolicy({required this.fee, required this.creditAmount});

  @override
  List<Object?> get props => [fee, creditAmount];
}
