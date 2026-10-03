import 'package:flutter/material.dart';

import 'package:nexpill/domain/dose_history.dart';
import 'package:nexpill/domain/inventory.dart';
import 'package:nexpill/domain/status.dart';
import 'package:nexpill/domain/wording.dart';
import 'package:nexpill/models/medication.dart';
import 'package:nexpill/models/patient.dart';
import 'package:nexpill/services/preferences.dart';
import 'package:nexpill/ui/care_store.dart';
import 'package:nexpill/ui/give_dose_sheet.dart';
import 'package:nexpill/ui/history_screen.dart';
import 'package:nexpill/ui/layout.dart';
import 'package:nexpill/ui/medication_card.dart';
import 'package:nexpill/ui/medication_editor.dart';
import 'package:nexpill/ui/patients_screen.dart';
import 'package:nexpill/ui/settings_screen.dart';

/// The home screen: one patient's medications, what needs doing first at
/// the top, each with a button to give it.
class CareScreen extends StatefulWidget {
  const CareScreen({
    super.key,
    required this.store,
    required this.patientId,
    required this.onSelectPatient,
  });

  final CareStore store;
  final String? patientId;
  final ValueChanged<String> onSelectPatient;

  @override
  State<CareScreen> createState() => _CareScreenState();
}

class _CareScreenState extends State<CareScreen> with WidgetsBindingObserver {
  bool _notificationsAllowed = true;

  CareStore get _store => widget.store;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkNotifications();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _checkNotifications();
  }

  Future<void> _checkNotifications() async {
    final allowed = await _store.notifications.notificationsAllowed();
    if (mounted) setState(() => _notificationsAllowed = allowed);
  }

  void _push(Widget screen) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => screen));

  Future<void> _give(Medication m, MedicationStatus status) async {
    if (!await confirmEarlyDose(context, m, status, _store.now)) return;
    if (!mounted) return;
    final entry = await showGiveDoseSheet(context, medication: m);
    if (entry == null) return;
    await Preferences.setLastGivenBy(entry.givenBy);
    final dose = await _store.change((repo) => repo.logDose(
          m.id,
          givenAt: entry.givenAt,
          doseText: entry.doseText,
          givenBy: entry.givenBy,
          notes: entry.notes,
        ));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('${m.name} logged, ${whenText(dose.givenAt, DateTime.now())}'),
      persist: false,
      action: SnackBarAction(
        label: 'Undo',
        onPressed: () => _store.change((repo) => repo.deleteDose(dose.id)),
      ),
    ));
  }

  Future<void> _action(Patient patient, Medication m, CardAction action) async {
    switch (action) {
      case CardAction.edit:
        _push(MedicationEditor(store: _store, patient: patient, existing: m));
      case CardAction.history:
        _push(HistoryScreen(store: _store, patient: patient, medicationId: m.id));
      case CardAction.stop:
        await _store.change((repo) => repo.setMedicationActive(m.id, false));
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('${m.name} stopped. Its history is kept.'),
          persist: false,
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () =>
                _store.change((repo) => repo.setMedicationActive(m.id, true)),
          ),
        ));
      case CardAction.resume:
        await _store.change((repo) => repo.setMedicationActive(m.id, true));
    }
  }

  Future<void> _switchPatient(Patient current) async {
    final choice = await showModalBottomSheet<Object>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          for (final p in _store.care.patients)
            ListTile(
              leading: Icon(p.id == current.id
                  ? Icons.radio_button_checked
                  : Icons.radio_button_off),
              title: Text(p.displayName),
              onTap: () => Navigator.pop(context, p),
            ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.person_add_alt),
            title: const Text('Add someone'),
            onTap: () => Navigator.pop(context, 'add'),
          ),
          ListTile(
            leading: const Icon(Icons.people_outline),
            title: const Text('Manage people'),
            onTap: () => Navigator.pop(context, 'manage'),
          ),
        ]),
      ),
    );
    if (!mounted) return;
    switch (choice) {
      case Patient p:
        widget.onSelectPatient(p.id);
      case 'add':
        final p = await addPatient(context, _store);
        if (p != null) widget.onSelectPatient(p.id);
      case 'manage':
        _push(PatientsScreen(store: _store, onOpen: widget.onSelectPatient));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _store,
      builder: (context, _) {
        if (!_store.loaded) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final patients = _store.care.patients;
        if (patients.isEmpty) return _Welcome(store: _store, onAdded: widget.onSelectPatient);
        final patient = patients.firstWhere((p) => p.id == widget.patientId,
            orElse: () => patients.first);
        return _patientView(context, patient);
      },
    );
  }

  Widget _patientView(BuildContext context, Patient patient) {
    final theme = Theme.of(context);
    final care = _store.care;
    final now = _store.now;
    final meds = [for (final m in care.medications) if (m.patientId == patient.id) m];
    final active = [
      for (final m in meds)
        if (m.active) (m, computeMedicationStatus(m, care.doses, now)),
    ]..sort((a, b) => compareByUrgency(a.$2, b.$2));
    final stopped = [for (final m in meds) if (!m.active) m];
    final wantsReminders = patient.notificationsEnabled &&
        active.any((e) => e.$1.reminders.enabled);

    return Scaffold(
      appBar: AppBar(
        title: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _switchPatient(patient),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Flexible(child: Text(patient.displayName, overflow: TextOverflow.ellipsis)),
              const Icon(Icons.expand_more),
            ]),
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Dose history',
            icon: const Icon(Icons.history),
            onPressed: () => _push(HistoryScreen(store: _store, patient: patient)),
          ),
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => _push(SettingsScreen(
                store: _store, onSelectPatient: widget.onSelectPatient)),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _push(MedicationEditor(store: _store, patient: patient)),
        icon: const Icon(Icons.add),
        label: const Text('Add medication'),
      ),
      body: RefreshIndicator(
        onRefresh: _store.refresh,
        child: ListView(
          padding: readablePadding(context,
              base: const EdgeInsets.fromLTRB(16, 4, 16, 96)),
          children: [
            if (wantsReminders && !_notificationsAllowed)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Card(
                  child: ListTile(
                    leading: Icon(Icons.notifications_off_outlined,
                        color: theme.colorScheme.error),
                    title: const Text('Reminders are off'),
                    subtitle: const Text('Allow notifications so they can reach you.'),
                    trailing: FilledButton(
                      onPressed: () async {
                        await _store.notifications.requestPermission();
                        await _checkNotifications();
                      },
                      child: const Text('Allow'),
                    ),
                  ),
                ),
              ),
            if (!patient.notificationsEnabled && active.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12, left: 8),
                child: Text('Reminders are off for ${patient.displayName}.',
                    style: theme.textTheme.bodySmall),
              ),
            if (active.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 64),
                child: Column(children: [
                  Icon(Icons.medication_outlined,
                      size: 48, color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(height: 12),
                  Text('No medications yet', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 6),
                  Text(
                    'Add ${patient.displayName}\'s first one, and Nexpill will '
                    'keep track of when each dose can be given.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Add a medication'),
                    onPressed: () =>
                        _push(MedicationEditor(store: _store, patient: patient)),
                  ),
                ]),
              ),
            for (final (m, status) in active) ...[
              MedicationCard(
                medication: m,
                status: status,
                inventory: computeInventoryStatus(m, care.doses),
                now: now,
                lastGivenBy: latestDose(m.id, care.doses)?.givenBy,
                onGive: () => _give(m, status),
                onAction: (a) => _action(patient, m, a),
              ),
              const SizedBox(height: 12),
            ],
            if (active.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.add),
                  label: Text('Add a medication for ${patient.displayName}'),
                  onPressed: () =>
                      _push(MedicationEditor(store: _store, patient: patient)),
                ),
              ),
            if (stopped.isNotEmpty)
              Theme(
                data: theme.copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  title: Text('Stopped (${stopped.length})',
                      style: theme.textTheme.titleSmall),
                  children: [
                    for (final m in stopped)
                      ListTile(
                        title: Text(m.name),
                        subtitle: Text(scheduleText(m.schedule)),
                        onTap: () => _push(MedicationEditor(
                            store: _store, patient: patient, existing: m)),
                        trailing: TextButton(
                          onPressed: () => _action(patient, m, CardAction.resume),
                          child: const Text('Resume'),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// First run: nobody to care for yet.
class _Welcome extends StatelessWidget {
  const _Welcome({required this.store, required this.onAdded});

  final CareStore store;
  final ValueChanged<String> onAdded;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(actions: [
        IconButton(
          tooltip: 'Settings',
          icon: const Icon(Icons.settings_outlined),
          onPressed: () => Navigator.push(context,
              MaterialPageRoute(
                  builder: (_) =>
                      SettingsScreen(store: store, onSelectPatient: onAdded))),
        ),
      ]),
      body: Readable(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Image.asset('assets/brand/nexpill_logo_512.png',
                  width: 112, height: 112, semanticLabel: 'Nexpill logo'),
              const SizedBox(height: 20),
              Text('Nexpill',
                  textAlign: TextAlign.center, style: theme.textTheme.displaySmall),
              const SizedBox(height: 12),
              Text(
                'Keeps track of when each dose was given and when the next one '
                'can be, and reminds you on time.',
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Everything stays on this phone. No account, no internet.',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                icon: const Icon(Icons.person_add_alt),
                label: const Text('Who are you caring for?'),
                onPressed: () async {
                  final p = await addPatient(context, store);
                  if (p != null) onAdded(p.id);
                },
              ),
              const SizedBox(height: 12),
              Text(
                'It can be yourself. You can add more people later.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
