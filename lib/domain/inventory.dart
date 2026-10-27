import 'package:nexpill/domain/dose_history.dart';
import 'package:nexpill/models/dose_event.dart';
import 'package:nexpill/models/medication.dart';
import 'package:nexpill/models/refill.dart';

enum InventoryLevel { ok, low, out }

class InventoryStatus {
  const InventoryStatus({
    required this.enabled,
    required this.configured,
    this.level,
    this.remaining,
    this.used = 0,
    this.refilled = 0,
    this.effectiveDoseCount = 0,
    this.lowSupplyThreshold,
  });

  /// Whether inventory is tracked for this medication at all.
  final bool enabled;

  /// Tracked, and given a starting quantity and a positive amount per dose.
  /// Without both, nothing can be counted.
  final bool configured;

  final InventoryLevel? level;
  final double? remaining;
  final double used;

  /// How much all of its refills added.
  final double refilled;
  final int effectiveDoseCount;
  final double? lowSupplyThreshold;
}

/// How much of [medication] is left.
///
/// Always worked out from the dose history and refills, never kept as a
/// running count:
///
///     remaining = initialQuantity + refills - effectiveDoses * doseAmount
///
/// so a correction replaces a dose rather than using up a second one, and
/// the count can't drift from the history it describes. The starting
/// quantity may be below zero when refills more than make up for it: it's
/// whatever makes the amount left come out as last entered.
InventoryStatus computeInventoryStatus(Medication medication,
    Iterable<DoseEvent> doseEvents, Iterable<Refill> refills) {
  if (!medication.inventoryEnabled) {
    return const InventoryStatus(enabled: false, configured: false);
  }

  final initial = medication.initialQuantity;
  final perDose = medication.doseAmount;
  final threshold = medication.lowSupplyThreshold ?? 0;
  final refilled = refillTotal(medication.id, refills);

  if (initial == null ||
      perDose == null ||
      initial + refilled < 0 ||
      perDose <= 0) {
    return InventoryStatus(
      enabled: true,
      configured: false,
      lowSupplyThreshold: threshold,
    );
  }

  final count = effectiveDoses(medication.id, doseEvents).length;
  final used = count * perDose;
  final remaining = initial + refilled - used;

  return InventoryStatus(
    enabled: true,
    configured: true,
    level: remaining <= 0
        ? InventoryLevel.out
        : remaining <= threshold
            ? InventoryLevel.low
            : InventoryLevel.ok,
    remaining: remaining,
    used: used,
    refilled: refilled,
    effectiveDoseCount: count,
    lowSupplyThreshold: threshold,
  );
}

/// How much [medicationId]'s refills have added in all.
double refillTotal(String medicationId, Iterable<Refill> refills) => refills
    .where((r) => r.medicationId == medicationId)
    .fold(0.0, (sum, r) => sum + r.amount);

/// [medication] ready for a refill. If more doses were logged than the
/// supply allowed, the count was wrong: the starting quantity goes up so
/// none is left, as the card already says, and the refill adds to that
/// rather than to a shortfall. Unchanged otherwise. Call only when the
/// status is configured.
Medication withShortfallCleared(Medication medication,
    Iterable<DoseEvent> doseEvents, Iterable<Refill> refills) {
  final remaining =
      computeInventoryStatus(medication, doseEvents, refills).remaining!;
  return remaining >= 0
      ? medication
      : medication.copyWith(
          initialQuantity: medication.initialQuantity! - remaining);
}
