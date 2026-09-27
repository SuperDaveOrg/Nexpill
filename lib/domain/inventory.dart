import 'package:nexpill/domain/dose_history.dart';
import 'package:nexpill/models/dose_event.dart';
import 'package:nexpill/models/medication.dart';

enum InventoryLevel { ok, low, out }

class InventoryStatus {
  const InventoryStatus({
    required this.enabled,
    required this.configured,
    this.level,
    this.remaining,
    this.used = 0,
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
  final int effectiveDoseCount;
  final double? lowSupplyThreshold;
}

/// How much of [medication] is left.
///
/// Always worked out from the dose history, never kept as a running count:
///
///     remaining = initialQuantity - effectiveDoses * doseAmount
///
/// so a correction replaces a dose rather than using up a second one, and
/// the count can't drift from the history it describes.
InventoryStatus computeInventoryStatus(
    Medication medication, Iterable<DoseEvent> doseEvents) {
  if (!medication.inventoryEnabled) {
    return const InventoryStatus(enabled: false, configured: false);
  }

  final initial = medication.initialQuantity;
  final perDose = medication.doseAmount;
  final threshold = medication.lowSupplyThreshold ?? 0;

  if (initial == null || perDose == null || initial < 0 || perDose <= 0) {
    return InventoryStatus(
      enabled: true,
      configured: false,
      lowSupplyThreshold: threshold,
    );
  }

  final count = effectiveDoses(medication.id, doseEvents).length;
  final used = count * perDose;
  final remaining = initial - used;

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
    effectiveDoseCount: count,
    lowSupplyThreshold: threshold,
  );
}
