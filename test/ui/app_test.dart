import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexpill/data/sample_data.dart';
import 'package:nexpill/models/care_snapshot.dart';
import 'package:nexpill/models/dose_event.dart';
import 'package:nexpill/models/medication.dart';
import 'package:nexpill/services/notification_service.dart';
import 'package:nexpill/ui/app.dart';
import 'package:nexpill/ui/care_store.dart';
import 'package:nexpill/ui/give_dose_sheet.dart';
import 'package:nexpill/ui/settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/fakes.dart';

/// Drives the real screens against an in-memory store.
void main() {
  late InMemoryCareRepository repo;
  late FakeNotifications notifications;
  late CareStore store;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    repo = InMemoryCareRepository();
    notifications = FakeNotifications();
    store = CareStore(repository: repo, notifications: notifications);
  });

  /// [tall] lays out every card at once; a list only builds what's on
  /// screen.
  Future<void> start(WidgetTester tester, {bool tall = false}) async {
    tester.view.physicalSize = Size(1080, tall ? 9000 : 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);
    await store.load();
    await tester.pumpWidget(NexpillApp(
        store: store, reminderTaps: ValueNotifier<ReminderTag?>(null)));
    await tester.pumpAndSettle();
  }

  testWidgets('first run: add someone, add a medication, give a dose', (tester) async {
    await start(tester);

    await tester.tap(find.text('Who are you caring for?'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Sam');
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();
    expect(find.text('No medications yet'), findsOneWidget);

    await tester.tap(find.text('Add medication'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextFormField, 'Name'), 'Amoxicillin');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Amoxicillin'), findsOneWidget);
    expect(find.text('Not given yet'), findsOneWidget);

    await tester.tap(find.text('Give'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Log dose'));
    await tester.pumpAndSettle();

    expect((await repo.doses()).length, 1);
    expect(find.textContaining('Next dose'), findsOneWidget);
    expect(find.textContaining('logged'), findsOneWidget, reason: 'snackbar');
    // The dose was planned into reminders: due in 4 hours.
    expect(notifications.lastPlan!.notifications.first.title, 'Amoxicillin due now');

    // An action no longer makes a snackbar persist, so it goes by itself
    // rather than covering the next screen's buttons.
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    expect(find.textContaining('logged'), findsNothing);
  });

  testWidgets('giving a dose early asks first', (tester) async {
    await repo.replaceAll(sampleCare(DateTime.now()));
    await start(tester, tall: true);

    // Ibuprofen was given 2 hours ago and must wait 6.
    final card = find.ancestor(
        of: find.textContaining('Ibuprofen', findRichText: true).first,
        matching: find.byType(Card));
    final give = find.descendant(of: card, matching: find.text('Give'));
    await tester.ensureVisible(give);
    await tester.pumpAndSettle();
    await tester.tap(give);
    await tester.pumpAndSettle();
    expect(find.text('This is early'), findsOneWidget);
    await tester.tap(find.text('Not yet'));
    await tester.pumpAndSettle();
    expect(find.text('Log dose'), findsNothing);
  });

  testWidgets('most urgent first', (tester) async {
    await repo.replaceAll(sampleCare(DateTime.now()));
    await start(tester, tall: true);
    final names = [
      for (final n in ['Amoxicillin', 'Acetaminophen', 'Prednisone'])
        (n, tester.getTopLeft(find.textContaining(n, findRichText: true).first).dy),
    ];
    // Amoxicillin is overdue; acetaminophen due in minutes; prednisone hours.
    expect(names[0].$2, lessThan(names[1].$2));
    expect(names[1].$2, lessThan(names[2].$2));
  });

  testWidgets('a finished course moves below, with the stopped ones', (tester) async {
    final sample = sampleCare(DateTime.now());
    await repo.replaceAll(CareSnapshot(
      patients: sample.patients,
      medications: [
        for (final m in sample.medications)
          if (m.id == 'sample-amox')
            Medication(
                id: m.id, patientId: m.patientId, name: m.name,
                defaultDoseText: m.defaultDoseText, schedule: m.schedule,
                reminders: m.reminders, course: const EndsAfterDoses(1))
          else
            m,
      ],
      doses: sample.doses,
    ));
    await start(tester, tall: true);

    expect(find.text('Finished (1)'), findsOneWidget);
    await tester.tap(find.text('Finished (1)'));
    await tester.pumpAndSettle();
    expect(find.text('Course finished: its 1 dose given'), findsOneWidget);
    await store.refresh();
    expect(notifications.lastPlan!.notifications
        .expand((n) => n.medicationIds)
        .contains('sample-amox'), isFalse);
  });

  testWidgets('tapping a card edits it; the list ends with an add button', (tester) async {
    await repo.replaceAll(sampleCare(DateTime.now()));
    await start(tester, tall: true);
    expect(find.text('Add a medication for Alex Rivera'), findsOneWidget);
    await tester.tap(find.textContaining('Amoxicillin', findRichText: true).first);
    await tester.pumpAndSettle();
    expect(find.text('Edit Amoxicillin'), findsOneWidget);
  });

  testWidgets('a correction keeps a blank "Given by"', (tester) async {
    SharedPreferences.setMockInitialValues({'last_given_by': 'Pat'});
    final m = sampleCare(DateTime.now()).medications.first;
    DoseEvent? correcting;
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (context) => TextButton(
          onPressed: () =>
              showGiveDoseSheet(context, medication: m, correcting: correcting),
          child: const Text('open'),
        ),
      ),
    ));
    String givenBy() => tester
        .widget<TextField>(find.widgetWithText(TextField, 'Given by'))
        .controller!
        .text;

    // A new dose offers the last name used...
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(givenBy(), 'Pat');
    Navigator.pop(tester.element(find.text('Given by')));
    await tester.pumpAndSettle();

    // ...but correcting one logged without a name keeps it blank.
    correcting = DoseEvent(id: 'd', medicationId: m.id, givenAt: DateTime.now());
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(givenBy(), '');
  });

  testWidgets('Settings shows restored people without reopening', (tester) async {
    await store.load();
    await tester.pumpWidget(MaterialApp(home: SettingsScreen(store: store)));
    await tester.pumpAndSettle();
    expect(find.text('0 on this phone'), findsOneWidget);

    final backup = sampleCare(DateTime.now());
    await store.change((repo) => repo.replaceAll(backup));
    await tester.pumpAndSettle();
    expect(find.text('${backup.patients.length} on this phone'), findsOneWidget);
  });
}
