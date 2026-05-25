import 'package:timezone/data/latest.dart' as timezone_data;
import 'package:timezone/timezone.dart' as timezone;

class AvailabilityTimeZone {
  static const String vietnamName = 'Asia/Ho_Chi_Minh';
  static const int vietnamOffsetMinutes = 420;
  static bool _initialized = false;

  const AvailabilityTimeZone._();

  static DateTime toWallTime(
    DateTime instant, {
    String? timezoneName,
    int? fallbackOffsetMinutes,
  }) {
    final location = _location(timezoneName);
    if (location != null) {
      return timezone.TZDateTime.from(instant.toUtc(), location);
    }
    return DateTime.fromMillisecondsSinceEpoch(
      instant.toUtc().millisecondsSinceEpoch +
          (fallbackOffsetMinutes ?? 0) * Duration.millisecondsPerMinute,
      isUtc: true,
    );
  }

  static DateTime fromWallTime(
    DateTime localDate,
    DateTime timeTemplate, {
    String? timezoneName,
    int? fallbackOffsetMinutes,
  }) {
    final location = _location(timezoneName);
    if (location != null) {
      return timezone.TZDateTime(
        location,
        localDate.year,
        localDate.month,
        localDate.day,
        timeTemplate.hour,
        timeTemplate.minute,
        timeTemplate.second,
        timeTemplate.millisecond,
        timeTemplate.microsecond,
      );
    }
    final wallClockUtc = DateTime.utc(
      localDate.year,
      localDate.month,
      localDate.day,
      timeTemplate.hour,
      timeTemplate.minute,
      timeTemplate.second,
      timeTemplate.millisecond,
      timeTemplate.microsecond,
    );
    return DateTime.fromMillisecondsSinceEpoch(
      wallClockUtc.millisecondsSinceEpoch -
          (fallbackOffsetMinutes ?? 0) * Duration.millisecondsPerMinute,
      isUtc: true,
    );
  }

  static timezone.Location? _location(String? timezoneName) {
    if (timezoneName == null || timezoneName.isEmpty) return null;
    if (!_initialized) {
      timezone_data.initializeTimeZones();
      _initialized = true;
    }
    try {
      return timezone.getLocation(timezoneName);
    } on timezone.LocationNotFoundException {
      return null;
    }
  }
}
