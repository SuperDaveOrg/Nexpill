import 'package:flutter/material.dart';

import 'package:nexpill/data/ids.dart';
import 'package:nexpill/models/patient.dart';
import 'package:nexpill/ui/care_store.dart';
import 'package:nexpill/ui/layout.dart';

/// Asks for a patient's name: to add someone new, or to rename [existing].
/// Null if cancelled.
Future<String?> showPatientNameDialog(
  BuildContext context, {
  required List<Patient> others,
  Patient? existing,
}) {
  final controller = TextEditingController(text: existing?.displayName ?? '');
  String? error;
  return showDialog<String>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        void submit() {
          final name = controller.text.trim();
          if (name.isEmpty) {
            setState(() => error = 'Enter a name.');
          } else if (others.any((p) =>
              p.id != existing?.id &&
              p.displayName.toLowerCase() == name.toLowerCase())) {
            setState(() => error = 'Someone already has that name.');
          } else {
            Navigator.pop(context, name);
          }
        }

        return AlertDialog(
          title: Text(existing == null ? 'Who are you caring for?' : 'Rename'),
          content: TextField(
            controller: controller,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: 'Name',
              hintText: 'A first name or nickname is fine',
              errorText: error,
            ),
            onSubmitted: (_) => submit(),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel')),
            TextButton(
                onPressed: submit,
                child: Text(existing == null ? 'Add' : 'Save')),
          ],
        );
      },
    ),
  );
}

/// Adds a patient after asking their name; returns them, or null.
Future<Patient?> addPatient(BuildContext context, CareStore store) async {
  final name =
      await showPatientNameDialog(context, others: store.care.patients);
  if (name == null) return null;
  final patient = Patient(id: newId(), displayName: name);
  await store.change((repo) => repo.savePatient(patient));
  return patient;
}

/// Everyone whose medications are tracked here.
class PatientsScreen extends StatelessWidget {
  const PatientsScreen({super.key, required this.store, this.onOpen});

  final CareStore store;

  /// Shows a person's medications on the home screen.
  final ValueChanged<String>? onOpen;

  Future<void> _rename(BuildContext context, Patient p) async {
    final name = await showPatientNameDialog(context,
        others: store.care.patients, existing: p);
    if (name != null) {
      await store.change((repo) => repo.savePatient(p.copyWith(displayName: name)));
    }
  }

  Future<void> _delete(BuildContext context, Patient p) async {
    final count =
        store.care.medications.where((m) => m.patientId == p.id).length;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete ${p.displayName}?'),
        content: Text(
          'Their ${count == 1 ? 'medication' : '$count medications'} and all '
          'dose history go too, and can\'t be brought back unless you have a '
          'backup file.',
        ),
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
    if (ok == true) await store.change((repo) => repo.deletePatient(p.id));
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final theme = Theme.of(context);
        final patients = store.care.patients;
        return Scaffold(
          appBar: AppBar(title: const Text('People')),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => addPatient(context, store),
            icon: const Icon(Icons.person_add_alt),
            label: const Text('Add someone'),
          ),
          body: ListView(
            padding: readablePadding(context,
                base: const EdgeInsets.fromLTRB(16, 8, 16, 96)),
            children: [
              for (final p in patients) ...[
                Card(
                  child: Column(children: [
                    ListTile(
                      title: Text(p.displayName, style: theme.textTheme.titleMedium),
                      subtitle: Text(onOpen == null
                          ? _medCount(p)
                          : '${_medCount(p)} · tap to see them'),
                      onTap: onOpen == null
                          ? null
                          : () {
                              onOpen!(p.id);
                              Navigator.popUntil(context, (r) => r.isFirst);
                            },
                      trailing: PopupMenuButton<String>(
                        onSelected: (v) => v == 'rename'
                            ? _rename(context, p)
                            : _delete(context, p),
                        itemBuilder: (_) => const [
                          PopupMenuItem(value: 'rename', child: Text('Rename')),
                          PopupMenuItem(value: 'delete', child: Text('Delete')),
                        ],
                      ),
                    ),
                    SwitchListTile(
                      title: const Text('Reminders'),
                      subtitle: Text(p.notificationsEnabled
                          ? 'As set for each medication'
                          : 'All off for ${p.displayName}'),
                      value: p.notificationsEnabled,
                      onChanged: (v) => store.change((repo) =>
                          repo.savePatient(p.copyWith(notificationsEnabled: v))),
                    ),
                  ]),
                ),
                const SizedBox(height: 12),
              ],
            ],
          ),
        );
      },
    );
  }

  String _medCount(Patient p) {
    final n = store.care.medications
        .where((m) => m.patientId == p.id && m.active)
        .length;
    return n == 1 ? '1 medication' : '$n medications';
  }
}
