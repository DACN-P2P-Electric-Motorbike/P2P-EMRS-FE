import '../../domain/entities/booking_policy.dart';

class BookingPolicyModel {
  final String defaultProtectionPlan;
  final List<ProtectionPlanPolicy> protectionPlans;
  final PrepaidChargingPolicy prepaidCharging;
  final RoadsideSupportPolicy roadsideSupport;

  const BookingPolicyModel({
    required this.defaultProtectionPlan,
    required this.protectionPlans,
    required this.prepaidCharging,
    required this.roadsideSupport,
  });

  factory BookingPolicyModel.fromJson(Map<String, dynamic> json) {
    const fallback = BookingPolicy.fallback;
    final defaultProtectionPlan = _asString(
      json['defaultProtectionPlan'],
      fallback.defaultProtectionPlan,
    ).toUpperCase();
    final rawPlans = json['protectionPlans'];
    final parsedPlans = rawPlans is List
        ? rawPlans
              .whereType<Map>()
              .map(
                (plan) => _protectionPlanFromJson(
                  Map<String, dynamic>.from(plan),
                  defaultProtectionPlan,
                ),
              )
              .toList()
        : <ProtectionPlanPolicy>[];

    return BookingPolicyModel(
      defaultProtectionPlan: defaultProtectionPlan,
      protectionPlans: parsedPlans.isEmpty
          ? fallback.protectionPlans
          : parsedPlans,
      prepaidCharging: _prepaidChargingFromJson(json['prepaidCharging']),
      roadsideSupport: _roadsideSupportFromJson(json['roadsideSupport']),
    );
  }

  BookingPolicy toEntity() {
    return BookingPolicy(
      defaultProtectionPlan: defaultProtectionPlan,
      protectionPlans: protectionPlans,
      prepaidCharging: prepaidCharging,
      roadsideSupport: roadsideSupport,
    );
  }

  static ProtectionPlanPolicy _protectionPlanFromJson(
    Map<String, dynamic> json,
    String defaultProtectionPlan,
  ) {
    final protectionPlan = _asString(
      json['protectionPlan'] ?? json['value'],
      'STANDARD',
    ).toUpperCase();
    final fallback = _fallbackProtectionPlan(protectionPlan);
    return ProtectionPlanPolicy(
      protectionPlan: protectionPlan,
      feeRate: _asDouble(json['feeRate'], fallback.feeRate),
      deductible: _asDouble(json['deductible'], fallback.deductible),
      coverageLimit: _asDouble(json['coverageLimit'], fallback.coverageLimit),
      isDefault: _asBool(
        json['isDefault'],
        protectionPlan == defaultProtectionPlan,
      ),
    );
  }

  static ProtectionPlanPolicy _fallbackProtectionPlan(String protectionPlan) {
    return BookingPolicy.fallback.protectionPlans.firstWhere(
      (plan) => plan.protectionPlan == protectionPlan,
      orElse: () => BookingPolicy.fallback.protectionPlans[1],
    );
  }

  static PrepaidChargingPolicy _prepaidChargingFromJson(Object? value) {
    const fallback = BookingPolicy.fallback;
    if (value is! Map) return fallback.prepaidCharging;
    final json = Map<String, dynamic>.from(value);
    return PrepaidChargingPolicy(
      fee: _asDouble(json['fee'], fallback.prepaidCharging.fee),
      creditPercent: _asInt(
        json['creditPercent'],
        fallback.prepaidCharging.creditPercent,
      ),
      requiresBatteryReturnMinimum: _asBool(
        json['requiresBatteryReturnMinimum'],
        fallback.prepaidCharging.requiresBatteryReturnMinimum,
      ),
    );
  }

  static RoadsideSupportPolicy _roadsideSupportFromJson(Object? value) {
    const fallback = BookingPolicy.fallback;
    if (value is! Map) return fallback.roadsideSupport;
    final json = Map<String, dynamic>.from(value);
    return RoadsideSupportPolicy(
      fee: _asDouble(json['fee'], fallback.roadsideSupport.fee),
      creditAmount: _asDouble(
        json['creditAmount'],
        fallback.roadsideSupport.creditAmount,
      ),
    );
  }

  static String _asString(Object? value, String fallback) {
    return value is String && value.isNotEmpty ? value : fallback;
  }

  static double _asDouble(Object? value, double fallback) {
    return value is num ? value.toDouble() : fallback;
  }

  static int _asInt(Object? value, int fallback) {
    return value is num ? value.toInt() : fallback;
  }

  static bool _asBool(Object? value, bool fallback) {
    return value is bool ? value : fallback;
  }
}
