import 'package:flutter/material.dart';

import 'package:nexpill/domain/dates.dart';
import 'package:nexpill/domain/wording.dart';
import 'package:nexpill/export/dose_history_csv.dart';
import 'package:nexpill/models/dose_event.dart';
import 'package:nexpill/models/patient.dart';
import 'package:nexpill/services/document_service.dart';
import 'package:nexpill/ui/care_store.dart';
import 'package:nexpill/ui/give_dose_sheet.dart';
import 'package:nexpill/ui/layout.dart';

/// Everything given to one patient, newest first, grouped by day — or to
/// one medication, given [medicationId].
///
/// History is an audit trail: a corrected entry stays, struck through, with
/// its correction beside it.
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

  Future<void> _export() async {
    final care = widget.store.care;
    try {
      final saved = await DocumentService().save(
        'nexpill-${_slug(widget.patient.displayName)}-doses-${isoDate(DateTime.now())}.csv',
        doseHistoryCsv(care, patientId: widget.patient.id),
        mimeType: 'text/csv',
      );
      if (saved && mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Dose history saved')));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Couldn\'t save the file')));
      }
    }
  }

  Future<void> _open(DoseEvent dose, {required bool replaced}) async {
    final medication = widget.store.care.medication(dose.medicationId);
    if (medication == null) return;
    final choice = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          if (!replaced)
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Correct time or details'),
              subtitle: const Text('Keeps the original, marked as corrected'),
              onTap: () => Navigator.pop(context, 'correct'),
            ),
          ListTile(
            leading: Icon(Icons.delete_outline,
                color: Theme.of(context).colorScheme.error),
            title: const Text('Delete entry'),
            subtitle: const Text('Only for a dose that was never given'),
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
        final ok = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete this entry?'),
            content: Text(
                '${medication.name}, ${dateTimeText(dose.givenAt)}. Use this '
                'only if the dose was never given; to fix its time, correct '
                'it instead. Any corrections of it go too.'),
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
        if (ok == true) await widget.store.change((repo) => repo.deleteDose(dose.id));
    }
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
          for (final m in care.medications)
            if (m.patientId == widget.patient.id) m.id: m,
        };
        final filter = _medicationId;
        final doses = [
          for (final d in care.doses)
            if (meds.containsKey(d.medicationId) &&
                (filter == null || d.medicationId == filter))
              d,
        ];
        final replaced = {for (final d in care.doses) ?d.supersedesId};

        final days = <DateTime, List<DoseEvent>>{};
        for (final d in doses) {
          days.putIfAbsent(dateOnly(d.givenAt.toLocal()), () => []).add(d);
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(filter == null
                ? '${widget.patient.displayName}\'s doses'
                : meds[filter]?.name ?? 'Doses'),
            actions: [
              IconButton(
                tooltip: 'Save as a spreadsheet (CSV)',
                icon: const Icon(Icons.file_download_outlined),
                onPressed: doses.isEmpty ? null : _export,
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
                    label: Text('Only ${meds[filter]?.name ?? ''}'),
                    onDeleted: () => setState(() => _medicationId = null),
                  ),
                ),
              if (doses.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 48),
                  child: Text('Nothing logged yet.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge),
                ),
              for (final MapEntry(key: day, value: entries) in days.entries) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 20, 8, 8),
                  child: Text(dayHeading(day, now).toUpperCase(),
                      style: theme.textTheme.labelSmall
                          ?.copyWith(color: theme.colorScheme.primary)),
                ),
                Card(
                  clipBehavior: Clip.antiAlias,
                  child: Column(children: [
                    for (final (i, d) in entries.indexed) ...[
                      if (i > 0) const Divider(indent: 16, endIndent: 16),
                      _entry(theme, d, meds[d.medicationId]?.name ?? '',
                          replaced: replaced.contains(d.id)),
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

  Widget _entry(ThemeData theme, DoseEvent d, String name, {required bool replaced}) {
    final details = [
      ?d.doseText,
      if (d.givenBy != null) 'by ${d.givenBy}',
      if (d.isCorrection) 'correction',
      if (replaced) 'corrected',
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
    return ListTile(
      onTap: () => _open(d, replaced: replaced),
      title: Text('${clockText(d.givenAt)}  ·  $name', style: strike),
      subtitle: subtitle.isEmpty ? null : Text(subtitle),
      isThreeLine: d.notes != null && details.isNotEmpty,
      trailing: const Icon(Icons.chevron_right),
    );
  }
}

String _slug(String s) =>
    s.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-').replaceAll(RegExp(r'^-|-$'), '');
