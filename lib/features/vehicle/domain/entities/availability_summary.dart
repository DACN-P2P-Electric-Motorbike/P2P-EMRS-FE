import 'package:equatable/equatable.dart';

enum PublicAvailabilityRuleType {
  available,
  blocked;

  static PublicAvailabilityRuleType fromString(String value) {
    return value.toUpperCase() == 'BLOCKED'
        ? PublicAvailabilityRuleType.blocked
        : PublicAvailabilityRuleType.available;
  }
}

enum PublicAvailabilityRecurrence {
  once,
  weekly;

  static PublicAvailabilityRecurrence fromString(String value) {
    return value.toUpperCase() == 'WEEKLY'
        ? PublicAvailabilityRecurrence.weekly
        : PublicAvailabilityRecurrence.once;
  }
}

class VehicleAvailabilityRule extends Equatable {
  final PublicAvailabilityRuleType type;
  final PublicAvailabilityRecurrence recurrence;
  final List<int> recurringWeekdays;
  final int? timezoneOffsetMinutes;
  final DateTime? recurrenceEndsAt;
  final DateTime startTime;
  final DateTime endTime;

  const VehicleAvailabilityRule({
    required this.type,
    required this.recurrence,
    this.recurringWeekdays = const [],
    this.timezoneOffsetMinutes,
    this.recurrenceEndsAt,
    required this.startTime,
    required this.endTime,
  });

  bool get isWeekly => recurrence == PublicAvailabilityRecurrence.weekly;

  @override
  List<Object?> get props => [
    type,
    recurrence,
    recurringWeekdays,
    timezoneOffsetMinutes,
    recurrenceEndsAt,
    startTime,
    endTime,
  ];
}

class VehicleAvailabilitySummary extends Equatable {
  final bool hasAvailableCalendar;
  final List<VehicleAvailabilityRule> rules;

  const VehicleAvailabilitySummary({
    required this.hasAvailableCalendar,
    this.rules = const [],
  });

  List<VehicleAvailabilityRule> get availableRules => rules
      .where((rule) => rule.type == PublicAvailabilityRuleType.available)
      .toList();

  List<VehicleAvailabilityRule> get blockedRules => rules
      .where((rule) => rule.type == PublicAvailabilityRuleType.blocked)
      .toList();

  @override
  List<Object?> get props => [hasAvailableCalendar, rules];
}
