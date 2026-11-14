import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexpill/l10n/app_localizations.dart';
import 'package:nexpill/ui/duration_field.dart';

void main() {
  Future<List<int>> pump(WidgetTester tester, int minutes) async {
    final picked = <int>[];
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: DurationField(minutes: minutes, onChanged: picked.add),
      ),
    ));
    return picked;
  }

  int shown(WidgetTester tester, String label) => tester
      .widget<DropdownButton<int>>(find.descendant(
          of: find.widgetWithText(DropdownButtonFormField<int>, label),
          matching: find.byType(DropdownButton<int>)))
      .value!;

  testWidgets('splits a duration into days, hours and minutes',
      (tester) async {
    await pump(tester, 2 * 1440 + 4 * 60 + 45);
    expect(shown(tester, 'Days'), 2);
    expect(shown(tester, 'Hours'), 4);
    expect(shown(tester, 'Minutes'), 45);
  });

  testWidgets('picking days keeps the hours and minutes', (tester) async {
    final picked = await pump(tester, 8 * 60 + 30);
    await tester.tap(find.widgetWithText(DropdownButtonFormField<int>, 'Days'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('5').last);
    await tester.pumpAndSettle();
    expect(picked, [5 * 1440 + 8 * 60 + 30]);
  });

  testWidgets('keeps a longer interval from a backup selectable',
      (tester) async {
    await pump(tester, 90 * 1440);
    expect(shown(tester, 'Days'), 90);
    expect(shown(tester, 'Hours'), 0);
  });
}
