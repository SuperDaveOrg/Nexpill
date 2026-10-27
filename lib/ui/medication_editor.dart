import 'package:flutter/material.dart';

import 'package:nexpill/data/ids.dart';
import 'package:nexpill/domain/dates.dart';
import 'package:nexpill/domain/dose_history.dart';
import 'package:nexpill/domain/wording.dart';
import 'package:nexpill/models/medication.dart';
import 'package:nexpill/models/patient.dart';
import 'package:nexpill/ui/care_store.dart';
import 'package:nexpill/ui/dialogs.dart';
import 'package:nexpill/ui/duration_field.dart';
import 'package:nexpill/ui/language.dart';
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
      : MedicationDraft.of(widget.existing!,
          givenSoFar:
              effectiveDoses(widget.existing!.id, widget.store.care.doses).length);
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
    final ok = await confirmAction(
      context,
      title: context.l.deleteMedicationTitle(m.name),
      message: context.l.deleteMedicationMessage,
      action: context.l.delete,
    );
    if (!ok) return;
    await widget.store.change((repo) => repo.deleteMedication(m.id));
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = context.l;
    return Scaffold(
      appBar: AppBar(
        title: Text(_d.isNew ? l.newMedication : l.editMedication(widget.existing!.name)),
        actions: [
          TextButton(onPressed: _saving ? null : _save, child: Text(l.save)),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: readablePadding(context, base: const EdgeInsets.only(bottom: 32)),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 4, 24, 0),
            child: Text(l.forPerson(personInSentence(widget.patient)),
                style: theme.textTheme.bodySmall),
          ),
          _fields([
            _text(l.fieldName, _d.name, (v) => _d.name = v,
                error: _errors['name'], autofocus: _d.isNew, hint: l.fieldNameHint),
            _text(l.fieldStrength, _d.strength, (v) => _d.strength = v,
                hint: l.fieldStrengthHint),
            _text(l.fieldPurpose, _d.purpose, (v) => _d.purpose = v,
                hint: l.fieldPurposeHint),
            _text(l.fieldUsualDose, _d.dose, (v) => _d.dose = v,
                error: _errors['dose'], hint: l.fieldUsualDoseHint),
            _text(l.fieldInstructions, _d.instructions, (v) => _d.instructions = v,
                hint: l.fieldInstructionsHint, maxLines: 3),
          ]),
          Section(title: l.sectionWhen, children: [_schedule(theme)]),
          if (_d.courseAvailable)
            Section(title: l.sectionHowLong, children: [_course(theme)]),
          Section(title: l.sectionReminders, children: _reminders()),
          Section(title: l.sectionSupply, children: _supply()),
          if (!_d.isNew)
            Section(children: [
              SwitchListTile(
                title: Text(l.takingThisNow),
                subtitle: Text(l.takingThisNowHint),
                value: _d.active,
                onChanged: (v) => _update(() => _d.active = v),
              ),
              ListTile(
                leading: Icon(Icons.delete_outline, color: theme.colorScheme.error),
                title: Text(l.deleteMedication,
                    style: TextStyle(color: theme.colorScheme.error)),
                onTap: _delete,
              ),
            ]),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
            child: FilledButton(
              onPressed: _saving ? null : _save,
              child: Text(_d.isNew ? l.addMedication : l.saveChanges),
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
    final l = context.l;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final (kind, label) in [
                (ScheduleKind.interval, l.kindInterval),
                (ScheduleKind.fixedTimes, l.kindFixedTimes),
                (ScheduleKind.prn, l.kindAsNeeded),
                (ScheduleKind.taper, l.kindTaper),
                (ScheduleKind.once, l.kindOnce),
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
                Text(l.every, style: theme.textTheme.titleSmall),
                const SizedBox(height: 8),
                DurationField(
                  minutes: _d.everyMinutes,
                  onChanged: (v) => _update(() => _d.everyMinutes = v),
                ),
                _hint(theme, l.intervalHint),
              ],
            ScheduleKind.prn => [
                Text(l.atLeastApart, style: theme.textTheme.titleSmall),
                const SizedBox(height: 8),
                DurationField(
                  minutes: _d.prnMinutes,
                  onChanged: (v) => _update(() => _d.prnMinutes = v),
                ),
                _hint(theme, l.asNeededHint),
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
                      label: Text(l.addTime),
                      onPressed: _addTime,
                    ),
                  ],
                ),
                _hint(theme, l.fixedTimesHint),
              ],
            ScheduleKind.taper => _taper(theme),
            ScheduleKind.once => [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ActionChip(
                      avatar: const Icon(Icons.event_outlined),
                      label: Text(dateText(_d.onceAt)),
                      onPressed: _pickOnceDay,
                    ),
                    ActionChip(
                      avatar: const Icon(Icons.schedule),
                      label: Text(clockText(_d.onceAt)),
                      onPressed: _pickOnceTime,
                    ),
                  ],
                ),
                _hint(theme, l.onceHint),
              ],
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
      helpText: context.l.timeOfDose,
    );
    if (picked == null) return;
    _update(() {
      final t = ClockTime(picked.hour, picked.minute);
      if (!_d.times.contains(t)) _d.times.add(t);
    });
  }

  Future<void> _pickOnceDay() async {
    final today = dateOnly(DateTime.now());
    final at = _d.onceAt;
    final day = dateOnly(at);
    final picked = await showDatePicker(
      context: context,
      initialDate: day,
      firstDate: day.isBefore(today) ? day : today,
      lastDate: DateTime(today.year + 2, today.month, today.day),
      helpText: context.l.dayOfDose,
    );
    if (picked == null) return;
    _update(() => _d.onceAt =
        DateTime(picked.year, picked.month, picked.day, at.hour, at.minute));
  }

  Future<void> _pickOnceTime() async {
    final at = _d.onceAt;
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(at),
      helpText: context.l.timeOfDose,
    );
    if (picked == null) return;
    _update(() => _d.onceAt =
        DateTime(at.year, at.month, at.day, picked.hour, picked.minute));
  }

  Widget _course(ThemeData theme) {
    final l = context.l;
    final given = _d.givenSoFar;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final (kind, label) in [
                (CourseKind.ongoing, l.courseUntilStopped),
                (CourseKind.lastDay, l.courseUntilDate),
                (CourseKind.doses, l.courseNumberOfDoses),
              ])
                ChoiceChip(
                  label: Text(label),
                  selected: _d.courseKind == kind,
                  onSelected: (_) => _update(() => _d.courseKind = kind),
                ),
            ],
          ),
          const SizedBox(height: 12),
          ...switch (_d.courseKind) {
            CourseKind.ongoing => [
                _hint(theme, l.courseOngoingHint),
              ],
            CourseKind.lastDay => [
                ActionChip(
                  avatar: const Icon(Icons.event_outlined),
                  label: Text(l.courseLastDayChip(dateText(_d.courseLastDay))),
                  onPressed: _pickLastDay,
                ),
                _hint(theme, l.courseLastDayHint),
              ],
            CourseKind.doses => [
                _text(given > 0 ? l.dosesStillToGive : l.numberOfDoses,
                    _d.dosesLeft, (v) => _d.dosesLeft = v,
                    error: _errors['course'],
                    hint: l.dosesHint,
                    keyboard: TextInputType.number),
                _hint(theme,
                    given > 0 ? l.courseDosesGivenHint(given) : l.courseDosesHint),
              ],
          },
        ],
      ),
    );
  }

  Future<void> _pickLastDay() async {
    final today = dateOnly(DateTime.now());
    final initial = _d.courseLastDay;
    final first = _d.isNew || !initial.isBefore(today)
        ? today
        : DateTime(initial.year, initial.month, initial.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial.isBefore(first) ? first : initial,
      firstDate: first,
      lastDate: DateTime(today.year + 2, today.month, today.day),
      helpText: context.l.lastDayOfCourse,
    );
    if (picked != null) _update(() => _d.courseLastDay = picked);
  }

  List<Widget> _taper(ThemeData theme) {
    final l = context.l;
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
                        child: Text(l.taperStepNumber(i + 1),
                            style: theme.textTheme.titleSmall)),
                    if (_d.taperSteps.length > 1)
                      IconButton(
                        tooltip: l.removeStep,
                        icon: const Icon(Icons.close),
                        onPressed: () => _update(() => _d.taperSteps.removeAt(i)),
                      ),
                  ]),
                  Wrap(spacing: 8, children: [
                    ActionChip(
                      label: Text(l.stepFrom(dateText(step.start))),
                      onPressed: () async {
                        final d = await pick(step.start);
                        if (d != null) _update(() => step.start = d);
                      },
                    ),
                    ActionChip(
                      label: Text(step.end == null
                          ? l.noEndDate
                          : l.stepUntil(dateText(step.end!))),
                      onPressed: () async {
                        final d = await pick(step.end ?? step.start.add(const Duration(days: 7)));
                        if (d != null) _update(() => step.end = d);
                      },
                    ),
                    if (step.end != null)
                      ActionChip(
                        label: Text(l.clearEnd),
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
        label: Text(l.addStep),
        onPressed: () => _update(() {
          final last = _d.taperSteps.isEmpty ? null : _d.taperSteps.last;
          final start = last?.end ?? dateOnly(now).add(const Duration(days: 7));
          last?.end ??= start;
          _d.taperSteps.add(TaperStepDraft(start: start, minutes: last?.minutes ?? 480));
        }),
      ),
      _hint(theme, l.taperHint),
    ];
  }

  List<Widget> _reminders() {
    final l = context.l;
    final prn = _d.kind == ScheduleKind.prn;
    return [
      SwitchListTile(
        title: Text(l.remindMe),
        subtitle: Text(prn ? l.remindAsNeededHint : l.remindHint),
        value: _d.remindersOn,
        onChanged: (v) => _update(() {
          _d.remindersOn = v;
          _d.remindersTouched = true;
        }),
      ),
      if (_d.remindersOn && !prn) ...[
        ListTile(
          title: Text(l.headsUp),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: SegmentedButton<int>(
              segments: [
                for (final m in ReminderSettings.earlyChoices)
                  ButtonSegment(
                      value: m, label: Text(m == 0 ? l.none : l.minutesShort(m))),
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
          title: Text(l.repeatWhileOverdue),
          trailing: DropdownButton<int>(
            value: _d.overdueRepeatMinutes,
            underline: const SizedBox(),
            items: [
              for (final m in {15, 30, 60, _d.overdueRepeatMinutes}.toList()..sort())
                DropdownMenuItem(
                    value: m, child: Text(l.everyDuration(shortDurationText(m)))),
            ],
            onChanged: (v) => _update(() => _d.overdueRepeatMinutes = v ?? 30),
          ),
        ),
        if (_d.alarmAvailable)
          SwitchListTile(
            title: Text(l.ringLikeAlarm),
            subtitle: Text(l.ringLikeAlarmHint),
            value: _d.alarm,
            onChanged: (v) => _update(() => _d.alarm = v),
          ),
      ],
    ];
  }

  List<Widget> _supply() => [
        SwitchListTile(
          title: Text(context.l.trackSupply),
          subtitle: Text(context.l.trackSupplyHint),
          value: _d.trackSupply,
          onChanged: (v) => _update(() => _d.trackSupply = v),
        ),
        if (_d.trackSupply)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: Column(children: [
              Row(children: [
                Expanded(
                  child: _text(context.l.amountLeft, _d.amountLeft ?? '',
                      (v) => _d.amountLeft = v,
                      keyboard: const TextInputType.numberWithOptions(decimal: true)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _text(context.l.unit, _d.unit, (v) => _d.unit = v,
                      hint: context.l.unitHint),
                ),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                  child: _text(context.l.eachDoseUses, _d.perDose, (v) => _d.perDose = v,
                      keyboard: const TextInputType.numberWithOptions(decimal: true)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _text(context.l.warnAt, _d.lowAt ?? '', (v) => _d.lowAt = v,
                      hint: context.l.optional,
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
