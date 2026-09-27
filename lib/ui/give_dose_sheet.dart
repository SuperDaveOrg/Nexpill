import 'package:flutter/material.dart';

import 'package:nexpill/domain/status.dart';
import 'package:nexpill/domain/wording.dart';
import 'package:nexpill/models/dose_event.dart';
import 'package:nexpill/models/medication.dart';
import 'package:nexpill/services/preferences.dart';

/// What was entered in [GiveDoseSheet].
class DoseEntry {
  const DoseEntry({
    required this.givenAt,
    this.doseText,
    this.givenBy,
    this.notes,
  });

  final DateTime givenAt;
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
  DateTime now,
) async {
  if (status.schedule.eligibleNow) return true;
  final minutes = status.minutesUntilEligible;
  final prn = medication.schedule is PrnSchedule;
  final answer = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('This is early'),
      content: Text(
        '${medication.name} ${prn ? 'can next be given' : 'is next due'} '
        '${whenText(status.schedule.nextEligibleAt, now)}, in '
        '${durationText(minutes)}. Log a dose now anyway?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Not yet'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Log it now'),
        ),
      ],
    ),
  );
  return answer ?? false;
}

/// Logs a dose — or, given [correcting], corrects one. Opens on "now" with
/// the usual dose filled in, so the common case is one tap.
Future<DoseEntry?> showGiveDoseSheet(
  BuildContext context, {
  required Medication medication,
  DoseEvent? correcting,
}) async {
  final givenBy = correcting?.givenBy ?? await Preferences.lastGivenBy();
  if (!context.mounted) return null;
  return showModalBottomSheet<DoseEntry>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _GiveDoseSheet(
      medication: medication,
      correcting: correcting,
      givenBy: givenBy,
    ),
  );
}

class _GiveDoseSheet extends StatefulWidget {
  const _GiveDoseSheet({
    required this.medication,
    required this.correcting,
    required this.givenBy,
  });

  final Medication medication;
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

  /// Null means "now", worked out when saved.
  late DateTime? _at = widget.correcting?.givenAt.toLocal();
  String? _error;

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
      helpText: 'Day it was given',
    );
    if (day == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(start),
      helpText: 'Time it was given',
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
      setState(() => _error = 'That time hasn\'t happened yet.');
      return;
    }
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final correcting = widget.correcting != null;
    final at = _at;
    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 0, 20, 20 + MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              correcting
                  ? 'Correct this ${widget.medication.name} entry'
                  : 'Give ${widget.medication.name}',
              style: theme.textTheme.titleLarge,
            ),
            if (correcting)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  'The original stays in history, marked as corrected.',
                  style: theme.textTheme.bodySmall,
                ),
              ),
            const SizedBox(height: 16),
            if (!correcting)
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: true, label: Text('Now')),
                  ButtonSegment(value: false, label: Text('Earlier')),
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
                title: Text('Given ${whenText(at, DateTime.now())}'),
                trailing: TextButton(
                    onPressed: _pickTime, child: const Text('Change')),
              ),
            if (_error != null)
              Text(_error!,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: theme.colorScheme.error)),
            const SizedBox(height: 12),
            TextField(
              controller: _dose,
              decoration: const InputDecoration(labelText: 'Dose'),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _givenBy,
              decoration: const InputDecoration(
                  labelText: 'Given by', hintText: 'Optional'),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notes,
              decoration:
                  const InputDecoration(labelText: 'Notes', hintText: 'Optional'),
              textCapitalization: TextCapitalization.sentences,
              maxLines: 2,
              minLines: 1,
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _save,
              child: Text(correcting ? 'Save correction' : 'Log dose'),
            ),
          ],
        ),
      ),
    );
  }
}
