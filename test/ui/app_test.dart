import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexpill/data/sample_data.dart';
import 'package:nexpill/services/notification_service.dart';
import 'package:nexpill/ui/app.dart';
import 'package:nexpill/ui/care_store.dart';
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

  testWidgets('tapping a card edits it; the list ends with an add button', (tester) async {
    await repo.replaceAll(sampleCare(DateTime.now()));
    await start(tester, tall: true);
    expect(find.text('Add a medication for Alex Rivera'), findsOneWidget);
    await tester.tap(find.textContaining('Amoxicillin', findRichText: true).first);
    await tester.pumpAndSettle();
    expect(find.text('Edit Amoxicillin'), findsOneWidget);
  });
}
