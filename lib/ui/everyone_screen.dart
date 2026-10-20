import 'package:flutter/material.dart';

import 'package:nexpill/domain/status.dart';
import 'package:nexpill/domain/wording.dart';
import 'package:nexpill/models/medication.dart';
import 'package:nexpill/models/patient.dart';
import 'package:nexpill/ui/care_store.dart';
import 'package:nexpill/ui/layout.dart';
import 'package:nexpill/ui/patients_screen.dart';
import 'package:nexpill/ui/settings_screen.dart';
import 'package:nexpill/ui/theme.dart';

/// The home screen when caring for more than one person: each of them with
/// the medication that needs doing first, so a glance answers "who's next?"
/// without opening anyone.
class EveryoneScreen extends StatelessWidget {
  const EveryoneScreen({super.key, required this.store, required this.onOpen});

  final CareStore store;

  /// Shows a person's medications.
  final ValueChanged<String> onOpen;

  void _push(BuildContext context, Widget screen) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => screen));

  @override
  Widget build(BuildContext context) {
    final care = store.care;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Everyone'),
        actions: [
          IconButton(
            tooltip: 'Manage people',
            icon: const Icon(Icons.manage_accounts_outlined),
            onPressed: () =>
                _push(context, PatientsScreen(store: store, onOpen: onOpen)),
          ),
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => _push(
                context, SettingsScreen(store: store, onSelectPatient: onOpen)),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final p = await addPatient(context, store);
          if (p != null) onOpen(p.id);
        },
        icon: const Icon(Icons.person_add_alt),
        label: const Text('Add someone'),
      ),
      body: RefreshIndicator(
        onRefresh: store.refresh,
        child: ListView(
          padding: readablePadding(context,
              base: const EdgeInsets.fromLTRB(16, 4, 16, 96)),
          children: [
            for (final p in care.patients) ...[
              _PersonCard(
                patient: p,
                meds: care.medicationsFor(p.id),
                store: store,
                onTap: () => onOpen(p.id),
              ),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}

/// One person: their name, and what's next for them.
class _PersonCard extends StatelessWidget {
  const _PersonCard({
    required this.patient,
    required this.meds,
    required this.store,
    required this.onTap,
  });

  final Patient patient;
  final List<Medication> meds;
  final CareStore store;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = StatusColors.of(context);
    final now = store.now;
    // Ordered as on their own screen, finished ones left out.
    final active = [
      for (final m in meds)
        if (m.active) (m, computeMedicationStatus(m, store.care.doses, now)),
    ]
      ..removeWhere((e) => e.$2.label == MedicationStatusLabel.finished)
      ..sort((a, b) => compareByUrgency(a.$2, b.$2));
    final alsoDue = active
        .skip(1)
        .where((e) =>
            e.$2.label.isLate || e.$2.label == MedicationStatusLabel.eligibleNow)
        .length;
    final muted = theme.textTheme.bodyMedium
        ?.copyWith(color: theme.colorScheme.onSurfaceVariant);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 8, 16),
          child: Row(children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(personName(patient), style: theme.textTheme.titleLarge),
                  const SizedBox(height: 6),
                  if (active.isEmpty)
                    Text(meds.isEmpty ? 'No medications yet' : 'Nothing to give now',
                        style: muted)
                  else ...[
                    _next(context, active.first.$1, active.first.$2,
                        colors.forStatus(active.first.$2.label,
                            theme.colorScheme.onSurface)),
                    if (alsoDue > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text('+ $alsoDue more due now',
                            style: theme.textTheme.bodyMedium),
                      ),
                  ],
                  if (!patient.notificationsEnabled && active.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text('Reminders off', style: theme.textTheme.bodySmall),
                    ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: theme.colorScheme.onSurfaceVariant),
          ]),
        ),
      ),
    );
  }

  /// The medication that needs doing first: "Amoxicillin  Due in 8 min",
  /// then when.
  Widget _next(
      BuildContext context, Medication m, MedicationStatus status, Color accent) {
    final theme = Theme.of(context);
    final (headline, detail) = cardText(status, m, store.now);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(TextSpan(children: [
          TextSpan(text: m.name, style: theme.textTheme.titleMedium),
          TextSpan(
            text: '  $headline',
            style: theme.textTheme.titleMedium
                ?.copyWith(color: accent, fontWeight: FontWeight.w600),
          ),
        ])),
        Text(detail, style: theme.textTheme.bodySmall),
      ],
    );
  }
}
