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

  bool overlapsRange(DateTime rangeStart, DateTime rangeEnd) {
    if (!isWeekly) {
      return startTime.isBefore(rangeEnd) && endTime.isAfter(rangeStart);
    }
    return _weeklyOccurrences(rangeStart, rangeEnd).any(
      (occurrence) =>
          occurrence.startTime.isBefore(rangeEnd) &&
          occurrence.endTime.isAfter(rangeStart),
    );
  }

  bool coversRange(DateTime rangeStart, DateTime rangeEnd) {
    if (!isWeekly) {
      return !startTime.isAfter(rangeStart) && !endTime.isBefore(rangeEnd);
    }
    return _weeklyOccurrences(rangeStart, rangeEnd).any(
      (occurrence) =>
          !occurrence.startTime.isAfter(rangeStart) &&
          !occurrence.endTime.isBefore(rangeEnd),
    );
  }

  List<_AvailabilityOccurrence> _weeklyOccurrences(
    DateTime rangeStart,
    DateTime rangeEnd,
  ) {
    final offsetMs = (timezoneOffsetMinutes ?? 0) * 60 * 1000;
    final durationMs = endTime.difference(startTime).inMilliseconds;
    if (durationMs <= 0 || recurringWeekdays.isEmpty) return const [];

    final anchorLocal = DateTime.fromMillisecondsSinceEpoch(
      startTime.millisecondsSinceEpoch + offsetMs,
      isUtc: true,
    );
    final scanStartLocal = DateTime.fromMillisecondsSinceEpoch(
      rangeStart.millisecondsSinceEpoch + offsetMs - durationMs,
      isUtc: true,
    );
    final scanEndLocal = DateTime.fromMillisecondsSinceEpoch(
      rangeEnd.millisecondsSinceEpoch + offsetMs,
      isUtc: true,
    );
    final weekdays = recurringWeekdays.toSet();
    final occurrences = <_AvailabilityOccurrence>[];

    var cursor = DateTime.utc(
      scanStartLocal.year,
      scanStartLocal.month,
      scanStartLocal.day,
    );
    final finalDate = DateTime.utc(
      scanEndLocal.year,
      scanEndLocal.month,
      scanEndLocal.day,
    );

    while (!cursor.isAfter(finalDate)) {
      if (weekdays.contains(cursor.weekday)) {
        final occurrenceUtc = DateTime.utc(
          cursor.year,
          cursor.month,
          cursor.day,
          anchorLocal.hour,
          anchorLocal.minute,
          anchorLocal.second,
          anchorLocal.millisecond,
          anchorLocal.microsecond,
        );
        final occurrenceStart = DateTime.fromMillisecondsSinceEpoch(
          occurrenceUtc.millisecondsSinceEpoch - offsetMs,
          isUtc: true,
        ).toLocal();
        if (!occurrenceStart.isBefore(startTime) &&
            (recurrenceEndsAt == null ||
                occurrenceStart.isBefore(recurrenceEndsAt!))) {
          occurrences.add(
            _AvailabilityOccurrence(
              startTime: occurrenceStart,
              endTime: occurrenceStart.add(Duration(milliseconds: durationMs)),
            ),
          );
        }
      }
      cursor = cursor.add(const Duration(days: 1));
    }
    return occurrences;
  }

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

  AvailabilityRangeEvaluation evaluateRange(
    DateTime rangeStart,
    DateTime rangeEnd,
  ) {
    if (!rangeEnd.isAfter(rangeStart)) {
      return const AvailabilityRangeEvaluation(
        status: AvailabilityRangeStatus.unavailable,
        message: 'Thời gian kết thúc phải sau thời gian bắt đầu',
      );
    }

    for (final rule in blockedRules) {
      if (rule.overlapsRange(rangeStart, rangeEnd)) {
        return const AvailabilityRangeEvaluation(
          status: AvailabilityRangeStatus.blocked,
          message: 'Khung giờ này trùng lịch tạm ngưng của xe',
        );
      }
    }

    if (hasAvailableCalendar) {
      final isCovered = availableRules.any(
        (rule) => rule.coversRange(rangeStart, rangeEnd),
      );
      if (!isCovered) {
        return const AvailabilityRangeEvaluation(
          status: AvailabilityRangeStatus.unavailable,
          message: 'Xe chỉ nhận thuê trong các khung lịch đã mở',
        );
      }
      return const AvailabilityRangeEvaluation(
        status: AvailabilityRangeStatus.available,
        message: 'Khung giờ này phù hợp với lịch khả dụng',
      );
    }

    return const AvailabilityRangeEvaluation(
      status: AvailabilityRangeStatus.available,
      message: 'Khung giờ này không trùng lịch tạm ngưng',
    );
  }

  @override
  List<Object?> get props => [hasAvailableCalendar, rules];
}

enum AvailabilityRangeStatus { available, unavailable, blocked }

class AvailabilityRangeEvaluation extends Equatable {
  final AvailabilityRangeStatus status;
  final String message;

  const AvailabilityRangeEvaluation({
    required this.status,
    required this.message,
  });

  bool get canBook => status == AvailabilityRangeStatus.available;

  @override
  List<Object?> get props => [status, message];
}

class _AvailabilityOccurrence {
  final DateTime startTime;
  final DateTime endTime;

  const _AvailabilityOccurrence({
    required this.startTime,
    required this.endTime,
  });
}
