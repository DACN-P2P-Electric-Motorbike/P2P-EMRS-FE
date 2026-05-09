import 'package:intl/intl.dart';

class VietnamTime {
  static const Duration utcOffset = Duration(hours: 7);

  const VietnamTime._();

  static DateTime fromUtcInstant(DateTime value) {
    return value.toUtc().add(utcOffset);
  }

  static String format(DateTime value, String pattern) {
    return DateFormat(pattern).format(fromUtcInstant(value));
  }

  static String toApiIsoString(DateTime vietnamWallTime) {
    final y = vietnamWallTime.year.toString().padLeft(4, '0');
    final mo = vietnamWallTime.month.toString().padLeft(2, '0');
    final d = vietnamWallTime.day.toString().padLeft(2, '0');
    final h = vietnamWallTime.hour.toString().padLeft(2, '0');
    final mi = vietnamWallTime.minute.toString().padLeft(2, '0');
    final s = vietnamWallTime.second.toString().padLeft(2, '0');
    final ms = vietnamWallTime.millisecond.toString().padLeft(3, '0');
    return '$y-$mo-${d}T$h:$mi:$s.$ms+07:00';
  }
}
