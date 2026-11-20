import 'package:flutter/material.dart';

import 'package:nexpill/domain/dose_history.dart';
import 'package:nexpill/domain/scheduling.dart';
import 'package:nexpill/domain/status.dart';
import 'package:nexpill/domain/wording.dart';
import 'package:nexpill/models/dose_event.dart';
import 'package:nexpill/models/medication.dart';
import 'package:nexpill/services/preferences.dart';
import 'package:nexpill/ui/dialogs.dart';
import 'package:nexpill/ui/language.dart';

/// What was entered in [GiveDoseSheet].
class DoseEntry {
  const DoseEntry({
    required this.givenAt,
    this.doseText,
    this.givenBy,
    this.notes,
    this.countsFor,
  });

  final DateTime givenAt;

  /// The set time it was said to be for; see [DoseEvent.countsFor].
  final DateTime? countsFor;
  final String? doseText;
  final String? givenBy;
  final String? notes;
}

/// Asks before logging a dose that isn't due yet: giving early is the
/// caregiver's call, but never by accident.
Future<bool> confirmEarlyDose(
  BuildContext context,
  Medication medication,
  MedicationStatus status,
  DateTime now, {
  required bool self,
}) async {
  if (status.schedule.eligibleNow) return true;
  final minutes = status.minutesUntilEligible;
  final prn = medication.schedule is PrnSchedule;
  final when = whenText(status.schedule.nextEligibleAt, now);
  final l = context.l;
  return confirmAction(
    context,
    title: l.earlyTitle,
    message: prn
        ? DoseWords(self: self)
            .earlyMessageAvailable(medication.name, when, durationText(minutes))
        : l.earlyMessageDue(medication.name, when, durationText(minutes)),
    cancel: l.notYet,
    action: l.logItNow,
  );
}

/// Logs a dose — or, given [correcting], corrects one. Opens on "now" with
/// the usual dose filled in, so the common case is one tap. With [self] the
/// dose is the phone's owner's own: taken, with no "Given by" to fill in.
/// [doses] is the history so far: at set times, a dose that could be for
/// either of two times has to say which.
Future<DoseEntry?> showGiveDoseSheet(
  BuildContext context, {
  required Medication medication,
  required bool self,
  required Iterable<DoseEvent> doses,
  DoseEvent? correcting,
}) async {
  // A correction starts from what was logged, even a blank "Given by";
  // only a new dose offers the last name used. Nobody else gives the
  // phone's owner their own.
  final givenBy = correcting != null
      ? correcting.givenBy
      : self
          ? null
          : await Preferences.lastGivenBy();
  if (!context.mounted) return null;
  return showModalBottomSheet<DoseEntry>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _GiveDoseSheet(
      medication: medication,
      self: self,
      // What was given, as it stood before the entry being corrected.
      doses: [
        for (final d in correcting == null ? doses : withoutEntry(doses, correcting))
          if (!d.skipped) d,
      ],
      correcting: correcting,
      givenBy: givenBy,
    ),
  );
}

class _GiveDoseSheet extends StatefulWidget {
  const _GiveDoseSheet({
    required this.medication,
    required this.self,
    required this.doses,
    required this.correcting,
    required this.givenBy,
  });

  final Medication medication;
  final bool self;
  final List<DoseEvent> doses;
  final DoseEvent? correcting;
  final String? givenBy;

  @override
  State<_GiveDoseSheet> createState() => _GiveDoseSheetState();
}

class _GiveDoseSheetState extends State<_GiveDoseSheet> {
  late final _dose = TextEditingController(
      text: widget.correcting?.doseText ?? widget.medication.defaultDoseText);
  late final _givenBy = TextEditingController(text: widget.givenBy ?? '');
  late final _notes = TextEditingController(text: widget.correcting?.notes ?? '');
  late final _words = DoseWords(self: widget.self);

  /// "Given by" is left out for the phone's owner's own dose, unless the
  /// entry being corrected already names someone.
  late final _askGivenBy =
      !widget.self || (widget.givenBy ?? '').isNotEmpty;

  /// Null means "now", worked out when saved.
  late DateTime? _at = widget.correcting?.givenAt.toLocal();

  /// The set time picked for a dose that could be for either of two.
  late DateTime? _countsFor = widget.correcting?.countsFor;
  String? _error;

  /// The two set times a dose given at [at] could be for, and which of
  /// them is picked, if either.
  (({DateTime late, DateTime early})?, DateTime?) _setTime(DateTime at) {
    final doubt = setTimesInDoubt(widget.medication, widget.doses, at);
    final picked = _countsFor;
    return (
      doubt,
      doubt != null &&
              picked != null &&
              (picked.isAtSameMomentAs(doubt.late) ||
                  picked.isAtSameMomentAs(doubt.early))
          ? picked
          : null,
    );
  }

  @override
  void dispose() {
    _dose.dispose();
    _givenBy.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final now = DateTime.now();
    final start = _at ?? now;
    final day = await showDatePicker(
      context: context,
      initialDate: start,
      firstDate: now.subtract(const Duration(days: 60)),
      lastDate: now,
      helpText: _words.dayGiven,
    );
    if (day == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(start),
      helpText: _words.timeGiven,
    );
    if (time == null) return;
    setState(() {
      _at = DateTime(day.year, day.month, day.day, time.hour, time.minute);
      _error = null;
    });
  }

  void _save() {
    final at = _at ?? DateTime.now();
    if (at.isAfter(DateTime.now().add(const Duration(minutes: 1)))) {
      setState(() => _error = context.l.timeInFuture);
      return;
    }
    final (doubt, picked) = _setTime(at);
    if (doubt != null && picked == null) {
      setState(() => _error = context.l.doseWhichError);
      return;
    }
    // With no doubt the engine works it out, but a correction that leaves
    // the time alone keeps what the original said.
    final original = widget.correcting;
    final countsFor = doubt != null
        ? picked
        : original != null && original.givenAt.isAtSameMomentAs(at)
            ? original.countsFor
            : null;
    String? text(TextEditingController c) =>
        c.text.trim().isEmpty ? null : c.text.trim();
    final dose = text(_dose);
    Navigator.pop(
      context,
      DoseEntry(
        givenAt: at,
        doseText: dose == widget.medication.defaultDoseText ? null : dose,
        givenBy: text(_givenBy),
        notes: text(_notes),
        countsFor: countsFor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = context.l;
    final correcting = widget.correcting != null;
    final at = _at;
    final now = DateTime.now();
    final (doubt, picked) = _setTime(at ?? now);
    // SafeArea keeps "Log dose" above a 3-button navigation bar; its bottom
    // padding drops to zero while the keyboard is up, which viewInsets covers.
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
            20, 0, 20, 20 + MediaQuery.viewInsetsOf(context).bottom),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                correcting
                    ? l.correctEntry(widget.medication.name)
                    : _words.giveMedication(widget.medication.name),
                style: theme.textTheme.titleLarge,
              ),
              if (correcting)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    l.originalStays,
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              const SizedBox(height: 16),
              if (!correcting)
                SegmentedButton<bool>(
                  segments: [
                    ButtonSegment(value: true, label: Text(l.now)),
                    ButtonSegment(value: false, label: Text(l.earlier)),
                  ],
                  selected: {at == null},
                  onSelectionChanged: (s) {
                    if (s.single) {
                      setState(() => _at = null);
                    } else {
                      _pickTime();
                    }
                  },
                ),
              if (at != null)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.schedule),
                  title: Text(_words.givenWhen(whenText(at, DateTime.now()))),
                  trailing:
                      TextButton(onPressed: _pickTime, child: Text(l.change)),
                ),
              if (doubt != null) ...[
                const SizedBox(height: 12),
                Text(l.doseWhichTitle, style: theme.textTheme.titleSmall),
                const SizedBox(height: 2),
                Text(l.doseWhichHint, style: theme.textTheme.bodySmall),
                const SizedBox(height: 6),
                Wrap(spacing: 8, children: [
                  for (final (slot, label) in [
                    (doubt.late, l.doseDueLate(whenText(doubt.late, now))),
                    (doubt.early, l.doseDueEarly(whenText(doubt.early, now))),
                  ])
                    ChoiceChip(
                      label: Text(label),
                      selected: picked != null && picked.isAtSameMomentAs(slot),
                      onSelected: (_) => setState(() {
                        _countsFor = slot;
                        _error = null;
                      }),
                    ),
                ]),
              ],
              if (_error != null)
                Text(_error!,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: theme.colorScheme.error)),
              const SizedBox(height: 12),
              TextField(
                controller: _dose,
                decoration: InputDecoration(labelText: l.dose),
                textCapitalization: TextCapitalization.sentences,
              ),
              if (_askGivenBy) ...[
                const SizedBox(height: 12),
                TextField(
                  controller: _givenBy,
                  decoration: InputDecoration(
                      labelText: l.givenBy, hintText: l.optional),
                  textCapitalization: TextCapitalization.words,
                ),
              ],
              const SizedBox(height: 12),
              TextField(
                controller: _notes,
                decoration:
                    InputDecoration(labelText: l.notes, hintText: l.optional),
                textCapitalization: TextCapitalization.sentences,
                maxLines: 2,
                minLines: 1,
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _save,
                child: Text(correcting ? l.saveCorrection : l.logDose),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
