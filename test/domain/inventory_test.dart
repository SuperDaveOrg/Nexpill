import 'package:flutter_test/flutter_test.dart';
import 'package:nexpill/domain/inventory.dart';
import 'package:nexpill/models/dose_event.dart';
import 'package:nexpill/models/medication.dart';
import 'package:nexpill/models/refill.dart';

Medication tracked({
  bool enabled = true,
  double initial = 100,
  double perDose = 25,
  double threshold = 25,
}) =>
    Medication(
      id: 'med-1',
      patientId: 'patient-1',
      name: 'Hydroxyzine',
      defaultDoseText: '25 mg',
      schedule: const IntervalSchedule(240),
      reminders: const ReminderSettings(enabled: true),
      inventoryEnabled: enabled,
      initialQuantity: initial,
      doseAmount: perDose,
      doseUnit: 'mg',
      lowSupplyThreshold: threshold,
    );

DoseEvent dose(String id, {String? corrects}) => DoseEvent(
      id: id,
      medicationId: 'med-1',
      givenAt: DateTime.parse('2026-04-08T08:00:00Z'),
      supersedesId: corrects,
    );

void main() {
  test('counts from effective dose history, so a correction isn\'t a second dose', () {
    final r = computeInventoryStatus(tracked(initial: 200), [
      dose('original'),
      dose('fix', corrects: 'original'),
      dose('second'),
    ], const []);
    expect(r.effectiveDoseCount, 2);
    expect(r.used, 50);
    expect(r.remaining, 150);
    expect(r.level, InventoryLevel.ok);
  });

  test('low at or below the threshold', () {
    final r = computeInventoryStatus(
        tracked(initial: 50, perDose: 10, threshold: 10),
        [dose('1'), dose('2'), dose('3'), dose('4')], const []);
    expect(r.remaining, 10);
    expect(r.level, InventoryLevel.low);
  });

  test('out at zero', () {
    final r = computeInventoryStatus(
        tracked(initial: 40, perDose: 20, threshold: 5), [dose('1'), dose('2')], const []);
    expect(r.remaining, 0);
    expect(r.level, InventoryLevel.out);
  });

  test('nothing to report when tracking is off', () {
    final r = computeInventoryStatus(tracked(enabled: false), [dose('1')], const []);
    expect(r.enabled, isFalse);
    expect(r.level, isNull);
    expect(r.remaining, isNull);
  });

  Refill refill(String id, double amount) => Refill(
      id: id,
      medicationId: 'med-1',
      refilledAt: DateTime.parse('2026-04-09T08:00:00Z'),
      amount: amount);

  group('refills', () {
    test('add to what\'s left, and only for their own medication', () {
      final r = computeInventoryStatus(tracked(initial: 60, perDose: 25),
          [dose('1'), dose('2')], [
        refill('a', 100),
        Refill(
            id: 'other',
            medicationId: 'med-2',
            refilledAt: DateTime.parse('2026-04-09T08:00:00Z'),
            amount: 500),
      ]);
      expect(r.refilled, 100);
      expect(r.remaining, 110);
      expect(r.level, InventoryLevel.ok);
    });

    test('can make up for a starting amount below zero', () {
      final m = tracked(initial: -40, perDose: 25);
      expect(computeInventoryStatus(m, [], const []).configured, isFalse);
      expect(computeInventoryStatus(m, [], [refill('a', 100)]).remaining, 60);
    });

    test('start from none left when more was given than there was', () {
      final events = [dose('1'), dose('2'), dose('3')];
      final ready =
          withShortfallCleared(tracked(initial: 50, perDose: 25), events, const []);
      expect(computeInventoryStatus(ready, events, const []).remaining, 0);
      expect(computeInventoryStatus(ready, events, [refill('a', 100)]).remaining,
          100);
    });

    test('leave a supply that isn\'t short as it was', () {
      final m = tracked(initial: 60, perDose: 25);
      expect(withShortfallCleared(m, [dose('1')], const []), same(m));
    });
  });
}
