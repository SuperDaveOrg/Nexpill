import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:nexpill/data/backup.dart';
import 'package:nexpill/data/sample_data.dart';
import 'package:nexpill/domain/dates.dart';
import 'package:nexpill/export/patient_summary.dart';
import 'package:nexpill/models/care_snapshot.dart';
import 'package:nexpill/models/patient.dart';
import 'package:nexpill/services/app_info.dart';
import 'package:nexpill/services/document_service.dart';
import 'package:nexpill/services/links.dart';
import 'package:nexpill/services/preferences.dart';
import 'package:nexpill/ui/about_screen.dart';
import 'package:nexpill/ui/care_store.dart';
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
    _checkPermissions();
    installedVersion().then((v) {
      if (mounted) setState(() => _version = v);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

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
    if (!await openInBrowser(uri)) {
      _say('No browser to open it with. Visit $websiteLabel instead.');
    }
  }

  void _say(String message) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(message)));

  Future<void> _save(String name, String text, String mimeType, String done) async {
    try {
      if (await _documents.save(name, text, mimeType: mimeType)) _say(done);
    } catch (_) {
      _say('Couldn\'t save the file.');
    }
  }

  Future<void> _backUp() => _save(
        backupFileName(DateTime.now()),
        encodeBackup(_store.care, exportedAt: DateTime.now()),
        'application/json',
        'Backup saved',
      );

  Future<void> _restore() async {
    final String? text;
    try {
      text = await _documents.open();
    } catch (_) {
      _say('Couldn\'t open that file.');
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
          title: const Text('Can\'t restore this file'),
          content: Text(e.message),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK')),
          ],
        ),
      );
      return;
    }
    if (!mounted) return;
    final people = backup.patients.length;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Replace everything with this backup?'),
        content: Text(
          'It has $people ${people == 1 ? 'person' : 'people'}, '
          '${backup.medications.length} medications and '
          '${backup.doses.length} doses logged. Everything now on this phone '
          'will be replaced by it.',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Replace')),
        ],
      ),
    );
    if (ok != true) return;
    await _store.change((repo) => repo.replaceAll(backup));
    _say('Restored');
  }

  Future<void> _summary() async {
    final patients = _store.care.patients;
    if (patients.isEmpty) return;
    final patient = patients.length == 1
        ? patients.single
        : await showDialog<Patient>(
            context: context,
            builder: (context) => SimpleDialog(
              title: const Text('Summary for'),
              children: [
                for (final p in patients)
                  SimpleDialogOption(
                    onPressed: () => Navigator.pop(context, p),
                    child: Text(p.displayName),
                  ),
              ],
            ),
          );
    if (patient == null) return;
    final now = DateTime.now();
    await _save(
      'nexpill-summary-${patient.displayName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-')}-${isoDate(now)}.txt',
      patientSummary(_store.care, patient, now: now),
      'text/plain',
      'Summary saved',
    );
  }

  Future<void> _deleteAll() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete all data?'),
        content: const Text(
            'Every person, medication and dose on this phone, and every '
            'reminder. This can\'t be undone; if you might want it back, save '
            'a backup first.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete everything')),
        ],
      ),
    );
    if (ok != true) return;
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
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: readablePadding(context, base: const EdgeInsets.only(bottom: 32)),
        children: [
          Section(title: 'Reminders', children: [
            ListTile(
              leading: Icon(notifications == false
                  ? Icons.notifications_off_outlined
                  : Icons.notifications_active_outlined),
              title: Text(notifications == false
                  ? 'Notifications are off'
                  : 'Notifications are on'),
              subtitle: Text(notifications == false
                  ? 'Reminders can\'t be shown until they\'re allowed.'
                  : 'Reminders will show on this phone.'),
              trailing: notifications == false
                  ? FilledButton(
                      onPressed: () async {
                        await _store.notifications.requestPermission();
                        await _checkPermissions();
                      },
                      child: const Text('Allow'))
                  : null,
            ),
            if (exact == false)
              ListTile(
                leading: Icon(Icons.warning_amber, color: theme.colorScheme.error),
                title: const Text('Reminders may be late'),
                subtitle: const Text(
                    'Android has turned off exact alarms for Nexpill. Turn '
                    '"Alarms & reminders" back on in the phone\'s settings for '
                    'the app.'),
              ),
            ListTile(
              leading: const Icon(Icons.send_outlined),
              title: const Text('Send a test reminder'),
              subtitle: const Text('Arrives in a few seconds.'),
              onTap: () async {
                await _store.notifications.sendTest();
                _say('Test reminder on its way');
              },
            ),
          ]),
          Section(title: 'People', children: [
            ListTile(
              leading: const Icon(Icons.people_outline),
              title: const Text('People you care for'),
              subtitle: Text('${_store.care.patients.length} on this phone'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(
                      builder: (_) => PatientsScreen(
                          store: _store, onOpen: widget.onSelectPatient))),
            ),
          ]),
          Section(title: 'Your data', children: [
            ListTile(
              leading: const Icon(Icons.save_alt),
              title: const Text('Back up to a file'),
              subtitle: const Text('Everything, saved wherever you choose.'),
              onTap: _backUp,
            ),
            ListTile(
              leading: const Icon(Icons.restore),
              title: const Text('Restore from a backup'),
              subtitle: const Text('Replaces what\'s on this phone.'),
              onTap: _restore,
            ),
            ListTile(
              leading: const Icon(Icons.description_outlined),
              title: const Text('Medication summary'),
              subtitle: const Text('Plain text, for a doctor or a handover.'),
              onTap: _store.care.patients.isEmpty ? null : _summary,
            ),
            ListTile(
              leading: Icon(Icons.delete_forever_outlined,
                  color: theme.colorScheme.error),
              title: Text('Delete all data',
                  style: TextStyle(color: theme.colorScheme.error)),
              onTap: _deleteAll,
            ),
          ]),
          Section(title: 'About', children: [
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('About Nexpill'),
              subtitle: const Text('Where your data lives, and why it\'s free'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => AboutScreen(version: _version))),
            ),
            ListTile(
              leading: const Icon(Icons.public),
              title: const Text('Website'),
              subtitle: const Text(websiteLabel),
              trailing: const Icon(Icons.open_in_new),
              onTap: () => _openLink(websiteUri),
            ),
            ListTile(
              leading: const Icon(Icons.feedback_outlined),
              title: const Text('Send feedback'),
              subtitle: const Text('A form on the website, in your browser.'),
              trailing: const Icon(Icons.open_in_new),
              onTap: () => _openLink(feedbackUri),
            ),
            if (_version != null)
              ListTile(title: const Text('Version'), subtitle: Text(_version!)),
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
