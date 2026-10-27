import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexpill/data/sample_data.dart';
import 'package:nexpill/domain/wording.dart';
import 'package:nexpill/l10n/app_localizations.dart';
import 'package:nexpill/models/care_snapshot.dart';
import 'package:nexpill/models/dose_event.dart';
import 'package:nexpill/models/medication.dart';
import 'package:nexpill/models/patient.dart';
import 'package:nexpill/services/notification_service.dart';
import 'package:nexpill/services/preferences.dart';
import 'package:nexpill/ui/app.dart';
import 'package:nexpill/ui/care_store.dart';
import 'package:nexpill/ui/give_dose_sheet.dart';
import 'package:nexpill/ui/language.dart';
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
  /// screen. [open] taps that person on the overview, to see their
  /// medications.
  Future<void> start(WidgetTester tester,
      {bool tall = false, String? open}) async {
    tester.view.physicalSize = Size(1080, tall ? 9000 : 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);
    await store.load();
    await tester.pumpWidget(NexpillApp(
        store: store, reminderTaps: ValueNotifier<ReminderTag?>(null)));
    await tester.pumpAndSettle();
    if (open != null) {
      await tester.tap(find.text(open));
      await tester.pumpAndSettle();
    }
  }

  testWidgets('first run: add someone, add a medication, give a dose', (tester) async {
    await start(tester);

    await tester.tap(find.text('Someone I care for'));
    await tester.pumpAndSettle();
    expect(find.text('This is me'), findsNothing, reason: 'they chose someone else');
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

  testWidgets('first run, for yourself: no name asked, and it says "you"',
      (tester) async {
    await start(tester);

    await tester.tap(find.text('Me'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    final me = (await repo.patients()).single;
    expect((me.isSelf, me.displayName), (true, ''));
    expect(find.text('You'), findsOneWidget, reason: 'the title');
    expect(find.textContaining('Add your first one'), findsOneWidget);

    await tester.tap(find.text('Add medication'));
    await tester.pumpAndSettle();
    expect(find.text('For you'), findsOneWidget);
    await tester.enterText(find.widgetWithText(TextFormField, 'Name'), 'Amoxicillin');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Give'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Log dose'));
    await tester.pumpAndSettle();
    expect(notifications.lastPlan!.notifications.first.body, startsWith('For you · '));

    // Someone added later can't also be you; you're listed first.
    await tester.tap(find.text('You'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add someone'));
    await tester.pumpAndSettle();
    expect(find.text('This is me'), findsNothing);
    await tester.enterText(find.byType(TextField), 'Alex');
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();
    expect([for (final p in await repo.patients()) personName(p)], ['You', 'Alex']);
  });

  testWidgets('in Spanish, and back to English from Settings', (tester) async {
    chosenLanguage.value = 'es';
    addTearDown(() async {
      chosenLanguage.value = null;
      await useLanguage(const Locale('en'));
    });
    await start(tester);

    await tester.tap(find.text('Para mí'));
    await tester.pumpAndSettle();
    expect(find.text('Tú'), findsOneWidget, reason: 'the title');
    await tester.tap(find.text('Añadir medicamento'));
    await tester.pumpAndSettle();
    expect(find.text('Para ti'), findsOneWidget);
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Nombre'), 'Amoxicilina');
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Registrar dosis'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Próxima dosis'), findsOneWidget);
    expect(notifications.lastPlan!.notifications.first.title,
        'Amoxicilina: toca ahora');

    // Reminders say things, so changing language replans them.
    await tester.tap(find.byTooltip('Ajustes'));
    await tester.pumpAndSettle();
    final language = find.widgetWithIcon(ListTile, Icons.translate);
    await tester.scrollUntilVisible(language, 200,
        scrollable: find.byType(Scrollable).first);
    await tester.ensureVisible(language);
    await tester.pumpAndSettle();
    expect(find.text('Español'), findsOneWidget, reason: 'the one picked');
    await tester.tap(language);
    await tester.pumpAndSettle();
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
    expect(find.text('Settings'), findsOneWidget);
    expect(notifications.lastPlan!.notifications.first.title,
        'Amoxicilina due now');
    expect(await Preferences.language(), 'en');
  });

  testWidgets('someone already added can become you', (tester) async {
    await repo.savePatient(const Patient(id: 'me', displayName: 'Me'));
    await start(tester);

    await tester.tap(find.text('Me'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Manage people'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Rename'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('This is me'));
    await tester.enterText(find.byType(TextField), '');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    final me = (await repo.patients()).single;
    expect((me.isSelf, me.displayName), (true, ''));
    expect(find.text('You'), findsOneWidget);
    expect(find.text('All off for you'), findsNothing);
  });

  testWidgets('giving a dose early asks first', (tester) async {
    await repo.replaceAll(sampleCare(DateTime.now()));
    await start(tester, tall: true, open: 'Alex Rivera');

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
    await start(tester, tall: true, open: 'Alex Rivera');
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
    await start(tester, tall: true, open: 'Alex Rivera');

    expect(find.text('Finished (1)'), findsOneWidget);
    await tester.tap(find.text('Finished (1)'));
    await tester.pumpAndSettle();
    expect(find.text('Course finished: its 1 dose given'), findsOneWidget);
    await store.refresh();
    expect(notifications.lastPlan!.notifications
        .expand((n) => n.medicationIds)
        .contains('sample-amox'), isFalse);
  });

  testWidgets('refill adds a new pack to what\'s left, and can be undone', (tester) async {
    await repo.replaceAll(sampleCare(DateTime.now()));
    await start(tester, tall: true, open: 'Alex Rivera');
    final left = find.textContaining('tablets left');
    final before = tester.widget<Text>(left).data!;
    final count = int.parse(before.split(' ').first);

    await tester.tap(find.byTooltip('More for Acetaminophen'));
    await tester.pumpAndSettle();
    expect(find.text('Refill'), findsOneWidget);
    await tester.tap(find.text('Refill'));
    await tester.pumpAndSettle();
    expect(find.text('Refill Acetaminophen'), findsOneWidget);
    await tester.enterText(find.byType(TextField), '100');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    expect(find.text('${count + 100} tablets left'), findsOneWidget);
    expect(find.text('Acetaminophen refilled. ${count + 100} tablets left.'),
        findsOneWidget);
    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(find.text(before), findsOneWidget);
  });

  testWidgets('tapping a card edits it; the list ends with an add button', (tester) async {
    await repo.replaceAll(sampleCare(DateTime.now()));
    await start(tester, tall: true, open: 'Alex Rivera');
    expect(find.text('Add a medication for Alex Rivera'), findsOneWidget);
    await tester.tap(find.textContaining('Amoxicillin', findRichText: true).first);
    await tester.pumpAndSettle();
    expect(find.text('Edit Amoxicillin'), findsOneWidget);
  });

  testWidgets('more than one person: everyone first, with what\'s next for each',
      (tester) async {
    await repo.replaceAll(sampleCare(DateTime.now()));
    await start(tester);

    expect(find.text('Everyone'), findsOneWidget);
    expect(find.text('Alex Rivera'), findsOneWidget);
    expect(find.text('Jordan Lee'), findsOneWidget);
    // Alex's amoxicillin is overdue, so it's the one shown.
    expect(find.textContaining('Amoxicillin', findRichText: true), findsOneWidget);
    expect(find.textContaining('Prednisone', findRichText: true), findsNothing);
    expect(find.textContaining('Vitamin D', findRichText: true), findsOneWidget);

    // Opening someone, then back, returns to everyone instead of leaving.
    await tester.tap(find.text('Jordan Lee'));
    await tester.pumpAndSettle();
    expect(find.text('Add a medication for Jordan Lee'), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Everyone'), findsOneWidget);

    // The app bar's back arrow does the same.
    await tester.tap(find.text('Alex Rivera'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('Everyone'), findsOneWidget);
  });

  testWidgets('one person: straight to their medications, no back arrow',
      (tester) async {
    final sample = sampleCare(DateTime.now());
    await repo.replaceAll(CareSnapshot(
      patients: [sample.patients.first],
      medications: [
        for (final m in sample.medications)
          if (m.patientId == sample.patients.first.id) m,
      ],
      doses: sample.doses,
    ));
    await start(tester);
    expect(find.text('Everyone'), findsNothing);
    expect(find.text('Alex Rivera'), findsOneWidget);
    expect(find.byType(BackButton), findsNothing);
  });

  testWidgets('a correction keeps a blank "Given by"', (tester) async {
    SharedPreferences.setMockInitialValues({'last_given_by': 'Pat'});
    final m = sampleCare(DateTime.now()).medications.first;
    DoseEvent? correcting;
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
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
    await tester.pumpWidget(MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: SettingsScreen(store: store)));
    await tester.pumpAndSettle();
    expect(find.text('0 on this phone'), findsOneWidget);

    final backup = sampleCare(DateTime.now());
    await store.change((repo) => repo.replaceAll(backup));
    await tester.pumpAndSettle();
    expect(find.text('${backup.patients.length} on this phone'), findsOneWidget);
  });
}
