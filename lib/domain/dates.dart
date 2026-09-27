library;

/// Date and time helpers.
///
/// Nexpill works with two kinds of time, and keeping them apart is most of
/// what makes the timing right:
///
/// - **Instants** — when a dose was given, when the next one is due. Intervals
///   are real elapsed time: "every 8 hours" is 8 hours even across a
///   daylight-saving change.
/// - **Wall-clock times and calendar days** — "08:00 every day", "from 5
///   June". These follow the phone's local clock.

/// Strips the time component, returning local midnight on the same day.
DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// `YYYY-MM-DD`, the storage format for calendar days.
String isoDate(DateTime d) {
  final m = d.month.toString().padLeft(2, '0');
  final day = d.day.toString().padLeft(2, '0');
  return '${d.year.toString().padLeft(4, '0')}-$m-$day';
}

/// Parses `YYYY-MM-DD` to local midnight, or null if it isn't a real date.
DateTime? tryParseIsoDate(String s) {
  final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(s);
  if (match == null) return null;
  final year = int.parse(match[1]!);
  final month = int.parse(match[2]!);
  final day = int.parse(match[3]!);
  final date = DateTime(year, month, day);
  // DateTime rolls 31 April over to 1 May; a real date survives unchanged.
  if (date.year != year || date.month != month || date.day != day) return null;
  return date;
}

/// Whole minutes in [d], rounded up. Negative durations round toward zero.
int ceilMinutes(Duration d) =>
    (d.inMicroseconds / Duration.microsecondsPerMinute).ceil();

/// Whole minutes in [d], rounded down.
int floorMinutes(Duration d) =>
    (d.inMicroseconds / Duration.microsecondsPerMinute).floor();

/// A time on the clock, like 08:00, with no date attached.
class ClockTime implements Comparable<ClockTime> {
  const ClockTime(this.hour, this.minute)
      : assert(hour >= 0 && hour < 24),
        assert(minute >= 0 && minute < 60);

  final int hour;
  final int minute;

  int get minutesOfDay => hour * 60 + minute;

  /// Parses `HH:mm`, exactly two digits each, or returns null.
  static ClockTime? tryParse(String s) {
    final match = RegExp(r'^(\d{2}):(\d{2})$').firstMatch(s);
    if (match == null) return null;
    final hour = int.parse(match[1]!);
    final minute = int.parse(match[2]!);
    if (hour > 23 || minute > 59) return null;
    return ClockTime(hour, minute);
  }

  /// This time on the local calendar day of [day].
  DateTime on(DateTime day) =>
      DateTime(day.year, day.month, day.day, hour, minute);

  @override
  int compareTo(ClockTime other) => minutesOfDay - other.minutesOfDay;

  @override
  bool operator ==(Object other) =>
      other is ClockTime && other.hour == hour && other.minute == minute;

  @override
  int get hashCode => minutesOfDay;

  @override
  String toString() =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
}
