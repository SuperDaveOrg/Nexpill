import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:nexpill/data/backup.dart';
import 'package:nexpill/data/sample_data.dart';
import 'package:nexpill/domain/wording.dart';
import 'package:nexpill/export/file_names.dart';
import 'package:nexpill/export/patient_summary.dart';
import 'package:nexpill/models/care_snapshot.dart';
import 'package:nexpill/models/patient.dart';
import 'package:nexpill/services/app_info.dart';
import 'package:nexpill/services/document_service.dart';
import 'package:nexpill/services/links.dart';
import 'package:nexpill/services/preferences.dart';
import 'package:nexpill/ui/about_screen.dart';
import 'package:nexpill/ui/care_store.dart';
import 'package:nexpill/ui/dialogs.dart';
import 'package:nexpill/ui/language.dart';
import 'package:nexpill/ui/layout.dart';
import 'package:nexpill/ui/patients_screen.dart';
import 'package:nexpill/ui/section.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, required this.store, this.onSelectPatient});

  final CareStore store;

  /// Shows a person's medications on the home screen.
  final ValueChanged<String>? onSelectPatient;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with WidgetsBindingObserver {
  final _documents = DocumentService();
  bool? _notificationsAllowed;
  bool? _exactAllowed;
  String? _version;

  CareStore get _store => widget.store;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // The people count and summary come from the store; a restore or the
    // sample data replaces it while this screen is open.
    _store.addListener(_changed);
    _checkPermissions();
    installedVersion().then((v) {
      if (mounted) setState(() => _version = v);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _store.removeListener(_changed);
    super.dispose();
  }

  void _changed() => setState(() {});

  /// Permissions may have been changed in system settings meanwhile.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final n = await _store.notifications.notificationsAllowed();
    final e = await _store.notifications.exactAlarmsAllowed();
    if (mounted) {
      setState(() {
        _notificationsAllowed = n;
        _exactAllowed = e;
      });
    }
  }

  Future<void> _openLink(Uri uri) async {
    if (!await openInBrowser(uri) && mounted) {
      _say(context.l.noBrowser(websiteLabel));
    }
  }

  void _say(String message) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(message)));

  Future<void> _backUp() => saveToFile(
        context,
        name: backupFileName(DateTime.now()),
        text: encodeBackup(_store.care, exportedAt: DateTime.now()),
        mimeType: 'application/json',
        done: context.l.backupSaved,
      );

  Future<void> _restore() async {
    final String? text;
    try {
      text = await _documents.open();
    } catch (_) {
      if (mounted) _say(context.l.couldNotOpen);
      return;
    }
    if (text == null || !mounted) return;
    final CareSnapshot backup;
    try {
      backup = decodeBackup(text);
    } on BackupFormatException catch (e) {
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(context.l.cantRestore),
          content: Text(e.message),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(context.l.ok)),
          ],
        ),
      );
      return;
    }
    if (!mounted) return;
    final people = backup.patients.length;
    final ok = await confirmAction(
      context,
      title: context.l.restoreTitle,
      message: context.l.restoreMessage(
          context.l.peopleCount(people),
          context.l.medicationCount(backup.medications.length),
          context.l.dosesLoggedCount(backup.doses.length)),
      action: context.l.replace,
    );
    if (!ok) return;
    await _store.change((repo) => repo.replaceAll(backup));
    if (mounted) _say(context.l.restored);
  }

  Future<void> _summary() async {
    final patients = _store.care.patients;
    if (patients.isEmpty) return;
    final patient = patients.length == 1
        ? patients.single
        : await showDialog<Patient>(
            context: context,
            builder: (context) => SimpleDialog(
              title: Text(context.l.summaryFor),
              children: [
                for (final p in patients)
                  SimpleDialogOption(
                    onPressed: () => Navigator.pop(context, p),
                    child: Text(personName(p)),
                  ),
              ],
            ),
          );
    if (patient == null || !mounted) return;
    // A summary is often for a doctor, who'll want a name on it.
    final named = patient.hasName ? patient : await _nameForSummary(patient);
    if (named == null || !mounted) return;
    final now = DateTime.now();
    await saveToFile(
      context,
      name: patientSummaryFileName(named, now),
      text: patientSummary(_store.care, named, now: now),
      mimeType: 'text/plain',
      done: context.l.summarySaved,
    );
  }

  /// Asks the phone's owner, who has no name set, what to put on their
  /// summary: their name, or nothing. Null if cancelled.
  Future<Patient?> _nameForSummary(Patient self) async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l.yourNameOnSummary),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            labelText: context.l.yourName,
            hintText: context.l.optional,
          ),
          onSubmitted: (v) => Navigator.pop(context, v.trim()),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(context.l.cancel)),
          TextButton(
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              child: Text(context.l.continueAction)),
        ],
      ),
    );
    return name == null ? null : self.copyWith(displayName: name);
  }

  /// The phone's language, or one of Nexpill's by its own name.
  Future<void> _chooseLanguage() async {
    final current = chosenLanguage.value;
    final picked = await showDialog<(String?,)>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(context.l.language),
        children: [
          for (final (code, name) in [
            (null, context.l.sameAsPhone),
            for (final MapEntry(:key, :value) in languageNames.entries) (key, value),
          ])
            ListTile(
              leading: Icon(code == current
                  ? Icons.radio_button_checked
                  : Icons.radio_button_off),
              title: Text(name),
              onTap: () => Navigator.pop(context, (code,)),
            ),
        ],
      ),
    );
    if (picked == null) return;
    chosenLanguage.value = picked.$1;
    await Preferences.setLanguage(picked.$1);
  }

  Future<void> _deleteAll() async {
    final ok = await confirmAction(
      context,
      title: context.l.deleteAllTitle,
      message: context.l.deleteAllMessage,
      action: context.l.deleteEverything,
    );
    if (!ok) return;
    await _store.change((repo) => repo.deleteAllData());
    await _store.notifications.cancelAll();
    await Preferences.clear();
    if (mounted) Navigator.popUntil(context, (r) => r.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final notifications = _notificationsAllowed;
    final exact = _exactAllowed;
    final l = context.l;
    return Scaffold(
      appBar: AppBar(title: Text(l.settings)),
      body: ListView(
        padding: readablePadding(context, base: const EdgeInsets.only(bottom: 32)),
        children: [
          Section(title: l.sectionReminders, children: [
            ListTile(
              leading: Icon(notifications == false
                  ? Icons.notifications_off_outlined
                  : Icons.notifications_active_outlined),
              title: Text(notifications == false
                  ? l.notificationsOff
                  : l.notificationsOn),
              subtitle: Text(notifications == false
                  ? l.notificationsOffHint
                  : l.notificationsOnHint),
              trailing: notifications == false
                  ? FilledButton(
                      onPressed: () async {
                        await _store.notifications.requestPermission();
                        await _checkPermissions();
                      },
                      child: Text(l.allow))
                  : null,
            ),
            if (exact == false)
              ListTile(
                leading: Icon(Icons.warning_amber, color: theme.colorScheme.error),
                title: Text(l.mayBeLate),
                subtitle: Text(l.mayBeLateHint),
              ),
            ListTile(
              leading: const Icon(Icons.send_outlined),
              title: Text(l.sendTest),
              subtitle: Text(l.sendTestHint),
              onTap: () async {
                await _store.notifications.sendTest();
                if (mounted) _say(l.testOnItsWay);
              },
            ),
          ]),
          Section(title: l.people, children: [
            ListTile(
              leading: const Icon(Icons.people_outline),
              title: Text(l.peopleYouCareFor),
              subtitle: Text(l.onThisPhone(_store.care.patients.length)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(
                      builder: (_) => PatientsScreen(
                          store: _store, onOpen: widget.onSelectPatient))),
            ),
          ]),
          Section(title: l.yourData, children: [
            ListTile(
              leading: const Icon(Icons.save_alt),
              title: Text(l.backUp),
              subtitle: Text(l.backUpHint),
              onTap: _backUp,
            ),
            ListTile(
              leading: const Icon(Icons.restore),
              title: Text(l.restore),
              subtitle: Text(l.restoreHint),
              onTap: _restore,
            ),
            ListTile(
              leading: const Icon(Icons.description_outlined),
              title: Text(l.medicationSummary),
              subtitle: Text(l.medicationSummaryHint),
              onTap: _store.care.patients.isEmpty ? null : _summary,
            ),
            ListTile(
              leading: Icon(Icons.delete_forever_outlined,
                  color: theme.colorScheme.error),
              title: Text(l.deleteAllData,
                  style: TextStyle(color: theme.colorScheme.error)),
              onTap: _deleteAll,
            ),
          ]),
          Section(title: l.language, children: [
            ListTile(
              leading: const Icon(Icons.translate),
              title: Text(l.language),
              subtitle: Text(chosenLanguage.value == null
                  ? l.sameAsPhoneNow(languageNames[l.localeName] ?? l.localeName)
                  : languageNames[chosenLanguage.value] ?? chosenLanguage.value!),
              onTap: _chooseLanguage,
            ),
          ]),
          Section(title: l.about, children: [
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: Text(l.aboutNexpill),
              subtitle: Text(l.aboutNexpillHint),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => AboutScreen(version: _version))),
            ),
            ListTile(
              leading: const Icon(Icons.public),
              title: Text(l.website),
              subtitle: const Text(websiteLabel),
              trailing: const Icon(Icons.open_in_new),
              onTap: () => _openLink(websiteUri),
            ),
            ListTile(
              leading: const Icon(Icons.feedback_outlined),
              title: Text(l.sendFeedback),
              subtitle: Text(l.sendFeedbackHint),
              trailing: const Icon(Icons.open_in_new),
              onTap: () => _openLink(feedbackUri),
            ),
            if (_version != null)
              ListTile(title: Text(l.version), subtitle: Text(_version!)),
          ]),
          if (kDebugMode)
            Section(title: 'Development', children: [
              ListTile(
                leading: const Icon(Icons.science_outlined),
                title: const Text('Replace everything with sample data'),
                subtitle: const Text('Fictional people, built around now.'),
                onTap: () async {
                  await _store.change(
                      (repo) => repo.replaceAll(sampleCare(DateTime.now())));
                  _say('Sample data loaded');
                },
              ),
            ]),
        ],
      ),
    );
  }
}
