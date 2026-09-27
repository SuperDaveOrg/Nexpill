import 'package:nexpill/models/dose_event.dart';

/// The doses of [medicationId] that still count: all of them except those a
/// correction has replaced. A correction counts in place of what it replaced,
/// and can itself be corrected.
List<DoseEvent> effectiveDoses(
    String medicationId, Iterable<DoseEvent> events) {
  final mine = [for (final e in events) if (e.medicationId == medicationId) e];
  final replaced = {for (final e in mine) ?e.supersedesId};
  return [for (final e in mine) if (!replaced.contains(e.id)) e];
}

/// The most recent effective dose of [medicationId], or null if none.
///
/// Two doses logged at the same instant are told apart by id, so the answer
/// never depends on the order history happens to be stored in.
DoseEvent? latestDose(String medicationId, Iterable<DoseEvent> events) {
  DoseEvent? latest;
  for (final e in effectiveDoses(medicationId, events)) {
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
