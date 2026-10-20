import 'package:flutter/material.dart';

import 'package:nexpill/data/ids.dart';
import 'package:nexpill/domain/wording.dart';
import 'package:nexpill/models/patient.dart';
import 'package:nexpill/ui/care_store.dart';
import 'package:nexpill/ui/dialogs.dart';
import 'package:nexpill/ui/layout.dart';

/// Who someone is: their name, and whether they're the phone's owner.
typedef PersonDetails = ({String name, bool isSelf});

/// Asks who someone is: to add someone new, or to change [existing]. Offers
/// "This is me" when [offerSelf] and nobody else already is; the name is
/// then optional. Null if cancelled.
Future<PersonDetails?> showPersonDialog(
  BuildContext context, {
  required List<Patient> others,
  Patient? existing,
  bool offerSelf = true,
}) {
  final controller = TextEditingController(text: existing?.displayName ?? '');
  final canBeSelf = (offerSelf || (existing?.isSelf ?? false)) &&
      !others.any((p) => p.isSelf && p.id != existing?.id);
  var isSelf = existing?.isSelf ?? false;
  String? error;
  return showDialog<PersonDetails>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        void submit() {
          final name = controller.text.trim();
          if (name.isEmpty && !isSelf) {
            setState(() => error = 'Enter a name.');
          } else if (name.isNotEmpty &&
              others.any((p) =>
                  p.id != existing?.id &&
                  p.displayName.toLowerCase() == name.toLowerCase())) {
            setState(() => error = 'Someone already has that name.');
          } else {
            Navigator.pop(context, (name: name, isSelf: isSelf));
          }
        }

        return AlertDialog(
          title: Text(existing == null
              ? 'Who are you caring for?'
              : existing.hasName
                  ? 'Rename'
                  : 'Your name'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(
              controller: controller,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: isSelf ? 'Your name' : 'Name',
                hintText: isSelf ? 'Optional' : 'A first name or nickname is fine',
                errorText: error,
              ),
              onSubmitted: (_) => submit(),
            ),
            if (canBeSelf)
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                title: const Text('This is me'),
                subtitle: const Text('For your own medications'),
                value: isSelf,
                onChanged: (v) => setState(() {
                  isSelf = v ?? false;
                  error = null;
                }),
              ),
          ]),
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

/// Adds a patient after asking who they are; returns them, or null.
Future<Patient?> addPatient(BuildContext context, CareStore store,
    {bool offerSelf = true}) async {
  final details = await showPersonDialog(context,
      others: store.care.patients, offerSelf: offerSelf);
  if (details == null) return null;
  final patient =
      Patient(id: newId(), displayName: details.name, isSelf: details.isSelf);
  await store.change((repo) => repo.savePatient(patient));
  return patient;
}

/// Adds the phone's owner without asking a name; they can add one later.
Future<Patient> addSelf(CareStore store) async {
  final patient = Patient(id: newId(), displayName: '', isSelf: true);
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
    final details = await showPersonDialog(context,
        others: store.care.patients, existing: p);
    if (details != null) {
      await store.change((repo) => repo.savePatient(
          p.copyWith(displayName: details.name, isSelf: details.isSelf)));
    }
  }

  Future<void> _delete(BuildContext context, Patient p) async {
    final count = store.care.medicationsFor(p.id).length;
    final ok = await confirmAction(
      context,
      title: p.isSelf ? 'Delete your medications?' : 'Delete ${p.displayName}?',
      message: '${p.isSelf ? 'Your' : 'Their'} '
          '${count == 1 ? 'medication' : '$count medications'} and all '
          'dose history go too, and can\'t be brought back unless you have a '
          'backup file.',
      action: 'Delete',
    );
    if (ok) await store.change((repo) => repo.deletePatient(p.id));
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
                      title: Text(personName(p), style: theme.textTheme.titleMedium),
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
                        itemBuilder: (_) => [
                          PopupMenuItem(
                              value: 'rename',
                              child: Text(p.hasName ? 'Rename' : 'Add your name')),
                          const PopupMenuItem(value: 'delete', child: Text('Delete')),
                        ],
                      ),
                    ),
                    SwitchListTile(
                      title: const Text('Reminders'),
                      subtitle: Text(p.notificationsEnabled
                          ? 'As set for each medication'
                          : 'All off for ${personInSentence(p)}'),
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
    final n = store.care.medicationsFor(p.id).where((m) => m.active).length;
    return n == 1 ? '1 medication' : '$n medications';
  }
}
