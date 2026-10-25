import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/material.dart';

import 'package:nexpill/data/care_repository.dart';
import 'package:nexpill/domain/wording.dart';
import 'package:nexpill/services/notification_service.dart';
import 'package:nexpill/services/preferences.dart';
import 'package:nexpill/services/reminder_sync.dart';
import 'package:nexpill/ui/app.dart';
import 'package:nexpill/ui/care_store.dart';
import 'package:nexpill/ui/language.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final taps = ValueNotifier<ReminderTag?>(null);
  final notifications = NotificationService();
  await notifications.init(
    onAction: onReminderAction,
    onTap: (response) => taps.value = ReminderTag.tryParse(response.payload),
  );
  taps.value = await notifications.launchTag();

  // Saved for the reminder isolate, which can't ask the phone. NexpillApp
  // keeps both in step with MediaQuery once it's on screen.
  use24HourClock = PlatformDispatcher.instance.alwaysUse24HourFormat;
  await Preferences.setUse24HourClock(use24HourClock);
  chosenLanguage.value = await Preferences.language();
  final language =
      resolveLanguage(chosenLanguage.value, PlatformDispatcher.instance.locales);
  await useLanguage(language);
  await Preferences.setLanguageInUse(language.languageCode);

  final store = CareStore(repository: CareRepository(), notifications: notifications);
  // Every start replans the week's reminders, so they never run out while
  // the app is in use.
  await store.refresh();

  runApp(NexpillApp(
    store: store,
    reminderTaps: taps,
  ));
}
