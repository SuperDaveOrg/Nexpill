import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:nexpill/data/care_repository.dart';
import 'package:nexpill/domain/reminder_planner.dart';
import 'package:nexpill/services/notification_service.dart';

/// Replans every reminder from what's in the database now.
///
/// Run after anything changes — a dose logged, a medication edited, a
/// restore — and on every app start. It's one read and a few hundred alarm
/// calls at most, so doing it wholesale is simpler than tracking what
/// changed, and it can't leave a stale reminder behind.
Future<void> syncReminders(
  NotificationService notifications, {
  CareRepository? repository,
  DateTime? now,
}) async {
  final care = await (repository ?? CareRepository()).snapshot();
  final plan = const ReminderPlanner().plan(care, from: now ?? DateTime.now());
  await notifications.apply(plan, care);
}

/// Handles "Mark given" and "Snooze" on a reminder.
///
/// Runs in a background isolate when Nexpill isn't open, so it sets up what
/// it needs itself and must stay a top-level entry point.
@pragma('vm:entry-point')
Future<void> onReminderAction(NotificationResponse response) async {
  WidgetsFlutterBinding.ensureInitialized();
  final tag = ReminderTag.tryParse(response.payload);
  if (tag == null) return;

  final repository = CareRepository();
  final notifications = NotificationService();
  await notifications.init(onAction: onReminderAction);
  final now = DateTime.now();

  switch (response.actionId) {
    case NotificationService.actionGiven:
      for (final id in tag.medicationIds) {
        if (await repository.medication(id) != null) {
          await repository.logDose(id, givenAt: now);
        }
      }
    case NotificationService.actionSnooze:
      final again = snoozedNotification(
        await repository.snapshot(),
        tag.medicationIds,
        now: now,
        at: now.add(const Duration(minutes: NotificationService.snoozeMinutes)),
      );
      if (again != null) await notifications.snooze(again, since: tag.at);
  }
  await syncReminders(notifications, repository: repository, now: now);
}
