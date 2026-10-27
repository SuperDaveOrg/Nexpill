import 'package:flutter/material.dart';

import 'package:nexpill/domain/dates.dart';
import 'package:nexpill/domain/wording.dart';
import 'package:nexpill/export/dose_history_csv.dart';
import 'package:nexpill/export/file_names.dart';
import 'package:nexpill/models/dose_event.dart';
import 'package:nexpill/models/medication.dart';
import 'package:nexpill/models/patient.dart';
import 'package:nexpill/models/refill.dart';
import 'package:nexpill/ui/care_store.dart';
import 'package:nexpill/ui/dialogs.dart';
import 'package:nexpill/ui/give_dose_sheet.dart';
import 'package:nexpill/ui/layout.dart';
import 'package:nexpill/ui/language.dart';

/// Everything given to one patient, newest first, grouped by day — or to
/// one medication, given [medicationId].
///
/// History is an audit trail: a corrected entry stays, struck through, with
/// its correction beside it. Refills are listed among the doses.
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({
    super.key,
    required this.store,
    required this.patient,
    this.medicationId,
  });

  final CareStore store;
  final Patient patient;
  final String? medicationId;

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late String? _medicationId = widget.medicationId;

  Future<void> _export() => saveToFile(
        context,
        name: doseHistoryFileName(widget.patient, DateTime.now()),
        text: doseHistoryCsv(widget.store.care, patientId: widget.patient.id),
        mimeType: 'text/csv',
        done: context.l.doseHistorySaved,
      );

  Future<void> _open(DoseEvent dose, {required bool replaced}) async {
    final medication = widget.store.care.medication(dose.medicationId);
    if (medication == null) return;
    final choice = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          if (!replaced && !dose.skipped)
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: Text(context.l.correctTimeOrDetails),
              subtitle: Text(context.l.keepsOriginal),
              onTap: () => Navigator.pop(context, 'correct'),
            ),
          ListTile(
            leading: Icon(Icons.delete_outline,
                color: Theme.of(context).colorScheme.error),
            title: Text(context.l.deleteEntry),
            subtitle: Text(dose.skipped
                ? context.l.deleteEntrySkippedHint
                : context.l.deleteEntryHint),
            onTap: () => Navigator.pop(context, 'delete'),
          ),
        ]),
      ),
    );
    if (!mounted) return;
    switch (choice) {
      case 'correct':
        final entry = await showGiveDoseSheet(context,
            medication: medication, correcting: dose);
        if (entry == null) return;
        await widget.store.change((repo) => repo.correctDose(
              dose,
              givenAt: entry.givenAt,
              doseText: entry.doseText,
              givenBy: entry.givenBy,
              notes: entry.notes,
            ));
      case 'delete':
        final ok = await confirmAction(
          context,
          title: context.l.deleteEntryTitle,
          message: dose.skipped
              ? context.l.deleteSkippedMessage(
                  medication.name, dateTimeText(dose.givenAt))
              : context.l.deleteDoseMessage(
                  medication.name, dateTimeText(dose.givenAt)),
          action: context.l.delete,
        );
        if (ok) await widget.store.change((repo) => repo.deleteDose(dose.id));
    }
  }

  /// Deletes a refill logged by mistake, after asking.
  Future<void> _deleteRefill(Refill refill, Medication medication) async {
    final ok = await confirmAction(
      context,
      title: context.l.deleteEntryTitle,
      message: context.l.deleteRefillMessage(
          medication.name,
          dateTimeText(refill.refilledAt),
          amountText(refill.amount, medication.doseUnit)),
      action: context.l.delete,
    );
    if (ok) await widget.store.change((repo) => repo.deleteRefill(refill.id));
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.store,
      builder: (context, _) {
        final theme = Theme.of(context);
        final care = widget.store.care;
        final now = widget.store.now;
        final meds = {
          for (final m in care.medicationsFor(widget.patient.id)) m.id: m,
        };
        final filter = _medicationId;
        final doses = [
          for (final d in care.doses)
            if (meds.containsKey(d.medicationId) &&
                (filter == null || d.medicationId == filter))
              d,
        ];
        final refills = [
          for (final r in care.refills)
            if (meds.containsKey(r.medicationId) &&
                (filter == null || r.medicationId == filter))
              r,
        ];
        final replaced = {for (final d in care.doses) ?d.supersedesId};

        // Doses and refills together, newest first.
        final entries = <(DateTime, String, Widget)>[
          for (final d in doses)
            (d.givenAt, d.id, _entry(theme, d, meds[d.medicationId]?.name ?? '',
                replaced: replaced.contains(d.id))),
          for (final r in refills)
            (r.refilledAt, r.id, _refill(r, meds[r.medicationId]!)),
        ]..sort((a, b) {
            final byTime = b.$1.compareTo(a.$1);
            return byTime != 0 ? byTime : b.$2.compareTo(a.$2);
          });
        final days = <DateTime, List<Widget>>{};
        for (final (at, _, tile) in entries) {
          days.putIfAbsent(dateOnly(at.toLocal()), () => []).add(tile);
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(filter == null
                ? widget.patient.isSelf
                    ? context.l.yourDoses
                    : context.l.personsDoses(widget.patient.displayName)
                : meds[filter]?.name ?? context.l.doses),
            actions: [
              IconButton(
                tooltip: context.l.saveAsCsv,
                icon: const Icon(Icons.file_download_outlined),
                onPressed: entries.isEmpty ? null : _export,
              ),
            ],
          ),
          body: ListView(
            padding: readablePadding(context,
                base: const EdgeInsets.fromLTRB(16, 0, 16, 32)),
            children: [
              if (filter != null)
                Align(
                  alignment: Alignment.centerLeft,
                  child: InputChip(
                    label: Text(context.l.onlyMedication(meds[filter]?.name ?? '')),
                    onDeleted: () => setState(() => _medicationId = null),
                  ),
                ),
              if (entries.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 48),
                  child: Text(context.l.nothingLogged,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge),
                ),
              for (final MapEntry(key: day, value: tiles) in days.entries) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 20, 8, 8),
                  child: Text(dayHeading(day, now).toUpperCase(),
                      style: theme.textTheme.labelSmall
                          ?.copyWith(color: theme.colorScheme.primary)),
                ),
                Card(
                  clipBehavior: Clip.antiAlias,
                  child: Column(children: [
                    for (final (i, tile) in tiles.indexed) ...[
                      if (i > 0) const Divider(indent: 16, endIndent: 16),
                      tile,
                    ],
                  ]),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _refill(Refill r, Medication medication) => ListTile(
        onTap: () => _deleteRefill(r, medication),
        title: Text('${clockText(r.refilledAt)}  ·  ${medication.name}'),
        subtitle: Text(context.l
            .historyRefill(amountText(r.amount, medication.doseUnit))),
        trailing: const Icon(Icons.chevron_right),
      );

  Widget _entry(ThemeData theme, DoseEvent d, String name, {required bool replaced}) {
    final details = [
      ?d.doseText,
      if (d.givenBy != null) context.l.historyBy(d.givenBy!),
      if (d.isCorrection) context.l.historyCorrection,
      if (replaced) context.l.historyCorrected,
    ];
    final strike = replaced
        ? TextStyle(
            decoration: TextDecoration.lineThrough,
            color: theme.colorScheme.onSurfaceVariant)
        : null;
    final subtitle = [
      if (details.isNotEmpty) details.join(' · '),
      ?d.notes,
    ].join('\n');
    if (d.skipped) {
      return ListTile(
        onTap: () => _open(d, replaced: replaced),
        title: Text('$name  ·  ${skippedText(d.givenAt)}',
            style: strike ??
                TextStyle(color: theme.colorScheme.onSurfaceVariant)),
        subtitle: replaced ? Text(context.l.historyCorrected) : null,
        trailing: const Icon(Icons.chevron_right),
      );
    }
    return ListTile(
      onTap: () => _open(d, replaced: replaced),
      title: Text('${clockText(d.givenAt)}  ·  $name', style: strike),
      subtitle: subtitle.isEmpty ? null : Text(subtitle),
      isThreeLine: d.notes != null && details.isNotEmpty,
      trailing: const Icon(Icons.chevron_right),
    );
  }
}
