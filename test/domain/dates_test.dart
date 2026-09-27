import 'package:flutter_test/flutter_test.dart';
import 'package:nexpill/domain/dates.dart';

void main() {
  group('tryParseIsoDate', () {
    test('reads a calendar day as local midnight', () {
      expect(tryParseIsoDate('2026-06-05'), DateTime(2026, 6, 5));
    });

    test('rejects dates that don\'t exist or aren\'t YYYY-MM-DD', () {
      for (final s in ['2026-02-30', '2026-13-01', '2026-6-5', '2026-06-05T00:00', '']) {
        expect(tryParseIsoDate(s), isNull, reason: s);
      }
    });

    test('round-trips through isoDate', () {
      expect(isoDate(tryParseIsoDate('2028-02-29')!), '2028-02-29');
    });
  });

  group('ClockTime', () {
    test('parses HH:mm', () {
      expect(ClockTime.tryParse('08:05'), const ClockTime(8, 5));
      expect(ClockTime.tryParse('23:59').toString(), '23:59');
    });

    test('rejects anything else', () {
      for (final s in ['8:05', '24:00', '12:60', '12:00:00', 'noon']) {
        expect(ClockTime.tryParse(s), isNull, reason: s);
      }
    });
  });

  test('minute rounding', () {
    const d = Duration(minutes: 2, seconds: 1);
    expect(ceilMinutes(d), 3);
    expect(floorMinutes(d), 2);
    expect(ceilMinutes(-d), -2);
  });
}
