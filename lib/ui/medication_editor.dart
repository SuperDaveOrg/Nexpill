import 'package:flutter/material.dart';

import 'package:nexpill/data/ids.dart';
import 'package:nexpill/domain/dates.dart';
import 'package:nexpill/domain/wording.dart';
import 'package:nexpill/models/medication.dart';
import 'package:nexpill/models/patient.dart';
import 'package:nexpill/ui/care_store.dart';
import 'package:nexpill/ui/duration_field.dart';
import 'package:nexpill/ui/layout.dart';
import 'package:nexpill/ui/medication_draft.dart';
import 'package:nexpill/ui/section.dart';

/// Adds a medication for [patient], or edits [existing].
class MedicationEditor extends StatefulWidget {
  const MedicationEditor({
    super.key,
    required this.store,
    required this.patient,
    this.existing,
  });

  final CareStore store;
  final Patient patient;
  final Medication? existing;

  @override
  State<MedicationEditor> createState() => _MedicationEditorState();
}

class _MedicationEditorState extends State<MedicationEditor> {
  late final MedicationDraft _d = widget.existing == null
      ? MedicationDraft.blank(widget.patient.id, DateTime.now())
      : MedicationDraft.of(widget.existing!);
  Map<String, String> _errors = {};
  bool _saving = false;

  void _update(VoidCallback change) => setState(() {
        change();
        if (_errors.isNotEmpty) _errors = _d.validate();
      });

  Future<void> _save() async {
    final errors = _d.validate();
    if (errors.isNotEmpty) {
      setState(() => _errors = errors);
      return;
    }
    setState(() => _saving = true);
    final m = _d.build(newId);
    await widget.store.change((repo) => repo.saveMedication(m));
    if (m.reminders.enabled &&
        !await widget.store.notifications.notificationsAllowed()) {
      await widget.store.notifications.requestPermission();
    }
    if (mounted) Navigator.pop(context, true);
  }

  Future<void> _delete() async {
    final m = widget.existing!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete ${m.name}?'),
        content: const Text(
            'Its dose history goes with it. To stop it but keep the history, '
            'turn off "Taking this now" instead.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete')),
        ],
      ),
    );
    if (ok != true) return;
    await widget.store.change((repo) => repo.deleteMedication(m.id));
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_d.isNew ? 'New medication' : 'Edit ${widget.existing!.name}'),
        actions: [
          TextButton(onPressed: _saving ? null : _save, child: const Text('Save')),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: readablePadding(context, base: const EdgeInsets.only(bottom: 32)),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 4, 24, 0),
            child: Text('For ${widget.patient.displayName}',
                style: theme.textTheme.bodySmall),
          ),
          _fields([
            _text('Name', _d.name, (v) => _d.name = v,
                error: _errors['name'], autofocus: _d.isNew, hint: 'e.g. Amoxicillin'),
            _text('Strength', _d.strength, (v) => _d.strength = v,
                hint: 'Optional, e.g. 500 mg'),
            _text('Usual dose', _d.dose, (v) => _d.dose = v,
                error: _errors['dose'], hint: 'e.g. 1 tablet, 5 ml'),
            _text('Instructions', _d.instructions, (v) => _d.instructions = v,
                hint: 'Optional, e.g. with food', maxLines: 3),
          ]),
          Section(title: 'When', children: [_schedule(theme)]),
          Section(title: 'Reminders', children: _reminders()),
          Section(title: 'Supply', children: _supply()),
          if (!_d.isNew)
            Section(children: [
              SwitchListTile(
                title: const Text('Taking this now'),
                subtitle: const Text(
                    'Turn off when it\'s stopped. It keeps its history but '
                    'stops reminding.'),
                value: _d.active,
                onChanged: (v) => _update(() => _d.active = v),
              ),
              ListTile(
                leading: Icon(Icons.delete_outline, color: theme.colorScheme.error),
                title: Text('Delete medication',
                    style: TextStyle(color: theme.colorScheme.error)),
                onTap: _delete,
              ),
            ]),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
            child: FilledButton(
              onPressed: _saving ? null : _save,
              child: Text(_d.isNew ? 'Add medication' : 'Save changes'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fields(List<Widget> children) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Column(children: [
          for (final c in children)
            Padding(padding: const EdgeInsets.only(bottom: 12), child: c),
        ]),
      );

  Widget _text(
    String label,
    String value,
    ValueChanged<String> onChanged, {
    String? error,
    String? hint,
    bool autofocus = false,
    int maxLines = 1,
    TextInputType? keyboard,
  }) =>
      TextFormField(
        initialValue: value,
        autofocus: autofocus,
        maxLines: maxLines,
        minLines: 1,
        keyboardType: keyboard,
        textCapitalization: keyboard == null
            ? TextCapitalization.sentences
            : TextCapitalization.none,
        decoration: InputDecoration(labelText: label, hintText: hint, errorText: error),
        onChanged: (v) => _update(() => onChanged(v)),
      );

  Widget _schedule(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final (kind, label) in const [
                (ScheduleKind.interval, 'Every few hours'),
                (ScheduleKind.fixedTimes, 'At set times'),
                (ScheduleKind.prn, 'As needed'),
                (ScheduleKind.taper, 'Taper'),
              ])
                ChoiceChip(
                  label: Text(label),
                  selected: _d.kind == kind,
                  onSelected: (_) => _update(() => _d.setKind(kind)),
                ),
            ],
          ),
          const SizedBox(height: 16),
          ...switch (_d.kind) {
            ScheduleKind.interval => [
                Text('Every', style: theme.textTheme.titleSmall),
                const SizedBox(height: 8),
                DurationField(
                  minutes: _d.everyMinutes,
                  onChanged: (v) => _update(() => _d.everyMinutes = v),
                ),
                _hint(theme, 'Counted from the last dose given.'),
              ],
            ScheduleKind.prn => [
                Text('At least this long apart', style: theme.textTheme.titleSmall),
                const SizedBox(height: 8),
                DurationField(
                  minutes: _d.prnMinutes,
                  onChanged: (v) => _update(() => _d.prnMinutes = v),
                ),
                _hint(theme, 'Never "due" — Nexpill shows when it can be '
                    'given again.'),
              ],
            ScheduleKind.fixedTimes => [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final t in [..._d.times]..sort())
                      InputChip(
                        label: Text(clockText(t.on(DateTime.now()))),
                        onDeleted: () => _update(() => _d.times.remove(t)),
                      ),
                    ActionChip(
                      avatar: const Icon(Icons.add),
                      label: const Text('Add time'),
                      onPressed: _addTime,
                    ),
                  ],
                ),
                _hint(theme, 'Every day, on this phone\'s clock.'),
              ],
            ScheduleKind.taper => _taper(theme),
          },
          if (_errors['schedule'] != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(_errors['schedule']!,
                  style: TextStyle(color: theme.colorScheme.error)),
            ),
        ],
      ),
    );
  }

  Widget _hint(ThemeData theme, String text) => Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(text, style: theme.textTheme.bodySmall),
      );

  Future<void> _addTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 8, minute: 0),
      helpText: 'Time of dose',
    );
    if (picked == null) return;
    _update(() {
      final t = ClockTime(picked.hour, picked.minute);
      if (!_d.times.contains(t)) _d.times.add(t);
    });
  }

  List<Widget> _taper(ThemeData theme) {
    final now = DateTime.now();
    Future<DateTime?> pick(DateTime initial) => showDatePicker(
          context: context,
          initialDate: initial,
          firstDate: now.subtract(const Duration(days: 365)),
          lastDate: now.add(const Duration(days: 365 * 2)),
        );
    return [
      for (final (i, step) in _d.taperSteps.indexed)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(color: theme.colorScheme.outlineVariant),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 4, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(
                        child: Text('Step ${i + 1}', style: theme.textTheme.titleSmall)),
                    if (_d.taperSteps.length > 1)
                      IconButton(
                        tooltip: 'Remove step',
                        icon: const Icon(Icons.close),
                        onPressed: () => _update(() => _d.taperSteps.removeAt(i)),
                      ),
                  ]),
                  Wrap(spacing: 8, children: [
                    ActionChip(
                      label: Text('From ${dateText(step.start)}'),
                      onPressed: () async {
                        final d = await pick(step.start);
                        if (d != null) _update(() => step.start = d);
                      },
                    ),
                    ActionChip(
                      label: Text(step.end == null
                          ? 'No end date'
                          : 'Until ${dateText(step.end!)}'),
                      onPressed: () async {
                        final d = await pick(step.end ?? step.start.add(const Duration(days: 7)));
                        if (d != null) _update(() => step.end = d);
                      },
                    ),
                    if (step.end != null)
                      ActionChip(
                        label: const Text('Clear end'),
                        onPressed: () => _update(() => step.end = null),
                      ),
                  ]),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: DurationField(
                      minutes: step.minutes,
                      onChanged: (v) => _update(() => step.minutes = v),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      OutlinedButton.icon(
        icon: const Icon(Icons.add),
        label: const Text('Add a step'),
        onPressed: () => _update(() {
          final last = _d.taperSteps.isEmpty ? null : _d.taperSteps.last;
          final start = last?.end ?? dateOnly(now).add(const Duration(days: 7));
          last?.end ??= start;
          _d.taperSteps.add(TaperStepDraft(start: start, minutes: last?.minutes ?? 480));
        }),
      ),
      _hint(theme, 'Each step runs from midnight on its first day until midnight '
          'on its end day. The last step can be open-ended.'),
    ];
  }

  List<Widget> _reminders() {
    final prn = _d.kind == ScheduleKind.prn;
    return [
      SwitchListTile(
        title: const Text('Remind me'),
        subtitle: Text(prn
            ? 'When it can be given again.'
            : 'When a dose is due, and again while it\'s overdue.'),
        value: _d.remindersOn,
        onChanged: (v) => _update(() {
          _d.remindersOn = v;
          _d.remindersTouched = true;
        }),
      ),
      if (_d.remindersOn && !prn) ...[
        ListTile(
          title: const Text('Heads-up before it\'s due'),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: SegmentedButton<int>(
              segments: [
                for (final m in ReminderSettings.earlyChoices)
                  ButtonSegment(value: m, label: Text(m == 0 ? 'None' : '$m min')),
              ],
              selected: {
                ReminderSettings.earlyChoices.contains(_d.earlyMinutes)
                    ? _d.earlyMinutes
                    : 0
              },
              onSelectionChanged: (s) => _update(() => _d.earlyMinutes = s.single),
            ),
          ),
        ),
        ListTile(
          title: const Text('Repeat while overdue'),
          trailing: DropdownButton<int>(
            value: _d.overdueRepeatMinutes,
            underline: const SizedBox(),
            items: [
              for (final m in {15, 30, 60, _d.overdueRepeatMinutes}.toList()..sort())
                DropdownMenuItem(value: m, child: Text('every ${shortDurationText(m)}')),
            ],
            onChanged: (v) => _update(() => _d.overdueRepeatMinutes = v ?? 30),
          ),
        ),
        if (_d.alarmAvailable)
          SwitchListTile(
            title: const Text('Ring like an alarm'),
            subtitle: const Text(
                'The alarm sound, repeating until you mark it given or snooze it.'),
            value: _d.alarm,
            onChanged: (v) => _update(() => _d.alarm = v),
          ),
      ],
    ];
  }

  List<Widget> _supply() => [
        SwitchListTile(
          title: const Text('Track how much is left'),
          subtitle: const Text('Counts down with each dose logged.'),
          value: _d.trackSupply,
          onChanged: (v) => _update(() => _d.trackSupply = v),
        ),
        if (_d.trackSupply)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: Column(children: [
              Row(children: [
                Expanded(
                  child: _text('Starting amount', _d.startingQuantity ?? '',
                      (v) => _d.startingQuantity = v,
                      keyboard: const TextInputType.numberWithOptions(decimal: true)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _text('Unit', _d.unit, (v) => _d.unit = v, hint: 'tablets'),
                ),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                  child: _text('Each dose uses', _d.perDose, (v) => _d.perDose = v,
                      keyboard: const TextInputType.numberWithOptions(decimal: true)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _text('Warn at', _d.lowAt ?? '', (v) => _d.lowAt = v,
                      hint: 'Optional',
                      keyboard: const TextInputType.numberWithOptions(decimal: true)),
                ),
              ]),
              if (_errors['supply'] != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(_errors['supply']!,
                      style: TextStyle(color: Theme.of(context).colorScheme.error)),
                ),
            ]),
          ),
      ];
}
