import 'package:nexpill/models/dose_event.dart';

/// The entries of [medicationId] that still count, skips included: all of
/// them except those a correction has replaced. A correction counts in place
/// of what it replaced, and can itself be corrected.
List<DoseEvent> effectiveEntries(
    String medicationId, Iterable<DoseEvent> events) {
  final mine = [for (final e in events) if (e.medicationId == medicationId) e];
  final replaced = {for (final e in mine) ?e.supersedesId};
  return [for (final e in mine) if (!replaced.contains(e.id)) e];
}

/// The doses of [medicationId] that still count and were given, not skipped.
List<DoseEvent> effectiveDoses(
        String medicationId, Iterable<DoseEvent> events) =>
    [for (final e in effectiveEntries(medicationId, events)) if (!e.skipped) e];

/// The most recent effective dose of [medicationId] that was given, or null
/// if none.
DoseEvent? latestDose(String medicationId, Iterable<DoseEvent> events) =>
    _latest(effectiveDoses(medicationId, events));

/// The most recent effective skip of [medicationId], or null if none.
DoseEvent? latestSkip(String medicationId, Iterable<DoseEvent> events) => _latest([
      for (final e in effectiveEntries(medicationId, events))
        if (e.skipped) e,
    ]);

/// How many of [medicationId]'s most recent effective entries in a row are
/// skips; 0 if the latest was given.
int skipsInARow(String medicationId, Iterable<DoseEvent> events) {
  final entries = effectiveEntries(medicationId, events)
    ..sort((a, b) {
      final byTime = b.givenAt.compareTo(a.givenAt);
      return byTime != 0 ? byTime : b.id.compareTo(a.id);
    });
  return entries.takeWhile((e) => e.skipped).length;
}

/// The most recent effective entry of [medicationId], given or skipped.
DoseEvent? latestEntry(String medicationId, Iterable<DoseEvent> events) =>
    _latest(effectiveEntries(medicationId, events));

/// Two entries logged at the same instant are told apart by id, so the
/// answer never depends on the order history happens to be stored in.
DoseEvent? _latest(List<DoseEvent> entries) {
  DoseEvent? latest;
  for (final e in entries) {
    if (latest == null) {
      latest = e;
      continue;
    }
    final byTime = e.givenAt.compareTo(latest.givenAt);
    if (byTime > 0 || (byTime == 0 && e.id.compareTo(latest.id) > 0)) {
      latest = e;
    }
  }
  return latest;
}
