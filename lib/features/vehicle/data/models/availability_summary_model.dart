import '../../domain/entities/availability_summary.dart';

class VehicleAvailabilityRuleModel extends VehicleAvailabilityRule {
  const VehicleAvailabilityRuleModel({
    required super.type,
    required super.recurrence,
    super.recurringWeekdays,
    super.timezoneOffsetMinutes,
    super.timezoneName,
    super.recurrenceEndsAt,
    required super.startTime,
    required super.endTime,
  });

  factory VehicleAvailabilityRuleModel.fromJson(Map<String, dynamic> json) {
    return VehicleAvailabilityRuleModel(
      type: PublicAvailabilityRuleType.fromString(json['type'] as String),
      recurrence: PublicAvailabilityRecurrence.fromString(
        json['recurrence'] as String? ?? 'ONCE',
      ),
      recurringWeekdays: (json['recurringWeekdays'] as List<dynamic>? ?? [])
          .map((day) => (day as num).toInt())
          .toList(),
      timezoneOffsetMinutes: (json['timezoneOffsetMinutes'] as num?)?.toInt(),
      timezoneName: json['timezoneName'] as String?,
      recurrenceEndsAt: json['recurrenceEndsAt'] == null
          ? null
          : DateTime.parse(json['recurrenceEndsAt'] as String).toLocal(),
      startTime: DateTime.parse(json['startTime'] as String).toLocal(),
      endTime: DateTime.parse(json['endTime'] as String).toLocal(),
    );
  }
}

class VehicleAvailabilitySummaryModel extends VehicleAvailabilitySummary {
  const VehicleAvailabilitySummaryModel({
    required super.hasAvailableCalendar,
    super.rules,
  });

  factory VehicleAvailabilitySummaryModel.fromJson(Map<String, dynamic> json) {
    return VehicleAvailabilitySummaryModel(
      hasAvailableCalendar: json['hasAvailableCalendar'] as bool? ?? false,
      rules: (json['rules'] as List<dynamic>? ?? [])
          .whereType<Map>()
          .map(
            (rule) => VehicleAvailabilityRuleModel.fromJson(
              Map<String, dynamic>.from(rule),
            ),
          )
          .toList(),
    );
  }

  VehicleAvailabilitySummary toEntity() {
    return VehicleAvailabilitySummary(
      hasAvailableCalendar: hasAvailableCalendar,
      rules: rules,
    );
  }
}
