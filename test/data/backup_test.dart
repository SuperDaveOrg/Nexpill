import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:nexpill/data/backup.dart';
import 'package:nexpill/data/sample_data.dart';
import 'package:nexpill/models/medication.dart';

void main() {
  final now = DateTime(2026, 6, 10, 12);
  final sample = sampleCare(now);

  Map<String, dynamic> sampleJson() =>
      jsonDecode(encodeBackup(sample, exportedAt: now)) as Map<String, dynamic>;

  /// Decodes [json] after [change] has broken it somehow.
  void refuses(void Function(Map<String, dynamic> json) change, String message) {
    final json = sampleJson();
    change(json);
    expect(
      () => decodeBackup(jsonEncode(json)),
      throwsA(isA<BackupFormatException>()
          .having((e) => e.message, 'message', contains(message))),
    );
  }

  Map<String, dynamic> firstMed(Map<String, dynamic> j) =>
      ((j['patients'] as List).first['medications'] as List).first
          as Map<String, dynamic>;

  test('round-trips everything', () {
    final back = decodeBackup(encodeBackup(sample, exportedAt: now));
    expect(back.patients.map((p) => p.id), sample.patients.map((p) => p.id));
    expect(back.medications.length, sample.medications.length);
    for (final m in sample.medications) {
      final b = back.medication(m.id)!;
      expect(b.name, m.name);
      expect(b.patientId, m.patientId);
      expect(b.schedule.typeName, m.schedule.typeName);
      expect(b.reminders.enabled, m.reminders.enabled);
      expect(b.reminders.earlyMinutes, m.reminders.earlyMinutes);
      expect(b.reminders.alarm, m.reminders.alarm);
      expect(b.initialQuantity, m.initialQuantity);
      if (m.schedule case TaperSchedule(:final rules)) {
        final back = (b.schedule as TaperSchedule).rules;
        expect([for (final r in back) r.startDate], [for (final r in rules) r.startDate]);
      }
    }
    expect({for (final d in back.doses) d.id: (d.givenAt, d.supersedesId)},
        {for (final d in sample.doses) d.id: (d.givenAt.toUtc(), d.supersedesId)});
  });

  test('is readable: pretty JSON, whole numbers, UTC instants', () {
    final text = encodeBackup(sample, exportedAt: now);
    expect(text, contains('\n  "patients": ['));
    expect(text, contains('"startingQuantity": 30,'));
    expect(text, matches(RegExp(r'"givenAt": "\d{4}-\d\d-\d\dT\d\d:\d\d:\d\d\.\d{3}Z"')));
  });

  test('accepts an instant with an offset', () {
    final json = sampleJson();
    ((firstMed(json)['doses'] as List).first as Map)['givenAt'] =
        '2026-06-10T10:00:00+02:00';
    final back = decodeBackup(jsonEncode(json));
    expect(back.doses.first.givenAt, DateTime.utc(2026, 6, 10, 8));
  });

  group('refuses', () {
    test('something that isn\'t JSON', () {
      expect(() => decodeBackup('not json'), throwsA(isA<BackupFormatException>()));
    });

    test('JSON that isn\'t a Nexpill backup', () {
      expect(() => decodeBackup('{"ebbBackup": 1}'),
          throwsA(isA<BackupFormatException>().having(
              (e) => e.message, 'message', contains('isn\'t a Nexpill backup'))));
    });

    test('a newer format', () => refuses((j) => j['nexpillBackup'] = 2, 'newer version'));

    test('a time without an offset', () => refuses(
        (j) => ((firstMed(j)['doses'] as List).first as Map)['givenAt'] = '2026-06-10T08:00:00',
        'time zone'));

    test('a duplicated id', () => refuses(
        (j) => ((firstMed(j)['doses'] as List).first as Map)['id'] = 'sample-alex',
        'more than once'));

    test('a correction of a dose that isn\'t there', () => refuses((j) {
          final amox = ((j['patients'] as List).first['medications'] as List)
              .firstWhere((m) => m['id'] == 'sample-amox') as Map;
          (amox['doses'] as List).removeWhere((d) => d['id'] == 'sample-d2');
        }, 'isn\'t in its history'));

    test('corrections in a circle', () => refuses((j) {
          final amox = ((j['patients'] as List).first['medications'] as List)
              .firstWhere((m) => m['id'] == 'sample-amox') as Map;
          (amox['doses'] as List)
              .firstWhere((d) => d['id'] == 'sample-d2')['corrects'] = 'sample-d3';
        }, 'circle'));

    test('an unknown schedule', () =>
        refuses((j) => (firstMed(j)['schedule'] as Map)['type'] = 'weekly', 'unknown schedule'));

    test('a bad clock time', () => refuses((j) {
          final drops = ((j['patients'] as List).first['medications'] as List)
              .firstWhere((m) => m['id'] == 'sample-drops') as Map;
          (drops['schedule'] as Map)['times'] = ['8am'];
        }, 'HH:mm'));

    test('a zero interval', () =>
        refuses((j) => (firstMed(j)['schedule'] as Map)['everyMinutes'] = 0, 'impossible'));

    test('an empty name', () =>
        refuses((j) => (j['patients'] as List).first['name'] = '  ', 'empty "name"'));
  });
}
