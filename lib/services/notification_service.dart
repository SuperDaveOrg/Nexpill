import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import 'package:nexpill/models/care_snapshot.dart';
import 'package:nexpill/domain/dose_history.dart';
import 'package:nexpill/domain/reminder_planner.dart';
import 'package:nexpill/domain/scheduling.dart';
import 'package:nexpill/models/medication.dart';

/// Hands the reminder plan to Android as exact alarms, and keeps the
/// notification shade truthful.
///
/// Every notification is local: the phone holds the alarm and fires it with
/// no network. Unlike Ebb's reminders these are *exact* — a medication
/// reminder that arrives twenty minutes late is a wrong one — using the
/// `USE_EXACT_ALARM` permission, which needs no prompt.
class NotificationService {
  NotificationService({FlutterLocalNotificationsPlugin? plugin})
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _ready = false;

  static const snoozeMinutes = 5;

  /// How a reminder is shown. [rings] is alarm mode: the alarm sound,
  /// repeating until acknowledged. [tag] is how it's found again in the
  /// shade. Every reminder, the test one included, is built here, so
  /// each Android channel always gets the same settings.
  static AndroidNotificationDetails _details({
    required bool rings,
    String? tag,
    bool multiline = false,
    bool withActions = true,
    bool canSkip = false,
  }) {
    final style = multiline ? const BigTextStyleInformation('') : null;
    final actions = withActions
        ? [_given, if (canSkip) _skip, _snooze]
        : null;
    if (rings) {
      return AndroidNotificationDetails(
        'alarms',
        'Medication alarms',
        channelDescription:
            'For medications set to ring like an alarm when a dose is due.',
        importance: Importance.max,
        priority: Priority.max,
        category: AndroidNotificationCategory.alarm,
        icon: _icon,
        actions: actions,
        sound: const UriAndroidNotificationSound(
            'content://settings/system/alarm_alert'),
        audioAttributesUsage: AudioAttributesUsage.alarm,
        // FLAG_INSISTENT: the sound repeats until the notification is dealt
        // with.
        additionalFlags: Int32List.fromList([4]),
        styleInformation: style,
        tag: tag,
      );
    }
    return AndroidNotificationDetails(
      'reminders',
      'Medication reminders',
      channelDescription: 'Heads-ups, doses due, and overdue doses.',
      importance: Importance.high,
      priority: Priority.high,
      category: AndroidNotificationCategory.reminder,
      icon: _icon,
      actions: actions,
      styleInformation: style,
      tag: tag,
    );
  }

  static const _upkeep = AndroidNotificationDetails(
    'upkeep',
    'Keeping reminders going',
    channelDescription:
        'A note when Nexpill needs opening so reminders don\'t run out.',
    icon: _icon,
  );

  static const _icon = 'ic_stat_nexpill';

  static const _given = AndroidNotificationAction(actionGiven, 'Mark given');
  static const _skip = AndroidNotificationAction(actionSkip, 'Skip');
  static const _snooze =
      AndroidNotificationAction(actionSnooze, 'Snooze $snoozeMinutes min');

  static const actionGiven = 'given';
  static const actionSkip = 'skip';
  static const actionSnooze = 'snooze';

  /// [onAction] handles "Mark given", "Skip" and "Snooze". It runs in a background
  /// isolate when the app isn't open, so it must be a top-level function
  /// marked `@pragma('vm:entry-point')`.
  Future<void> init({
    DidReceiveBackgroundNotificationResponseCallback? onAction,
    DidReceiveNotificationResponseCallback? onTap,
  }) async {
    if (_ready) return;
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings(_icon),
      ),
      onDidReceiveNotificationResponse: (response) {
        if (response.actionId != null) {
          onAction?.call(response);
        } else {
          onTap?.call(response);
        }
      },
      onDidReceiveBackgroundNotificationResponse: onAction,
    );
    _ready = true;
  }

  AndroidFlutterLocalNotificationsPlugin? get _android =>
      _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

  /// Asks to post notifications (Android 13+). False if declined.
  Future<bool> requestPermission() async =>
      await _android?.requestNotificationsPermission() ?? false;

  Future<bool> notificationsAllowed() async =>
      await _android?.areNotificationsEnabled() ?? false;

  /// Whether alarms will be exact. With USE_EXACT_ALARM this is true unless
  /// the system has overridden it.
  Future<bool> exactAlarmsAllowed() async =>
      await _android?.canScheduleExactNotifications() ?? false;

  /// Replaces every scheduled reminder with [plan], and clears shown or
  /// snoozed notifications for doses that have since been given.
  Future<void> apply(ReminderPlan plan, CareSnapshot care) async {
    for (final pending in await _plugin.pendingNotificationRequests()) {
      final tag = ReminderTag.tryParse(pending.payload);
      if (pending.id >= _snoozeBase && tag != null && !tag.stillDue(care)) {
        await _plugin.cancel(id: pending.id);
      } else if (pending.id < _snoozeBase && pending.id != _testId) {
        await _plugin.cancel(id: pending.id);
      }
    }

    for (final n in plan.notifications) {
      final tag = ReminderTag(n.at, n.medicationIds);
      await _schedule(_plannedId(n), n, tag);
    }

    if (plan.refreshNoticeAt case final at?) {
      await _plugin.zonedSchedule(
        id: _refreshNoticeId,
        title: 'Open Nexpill to keep reminders coming',
        body: 'Reminders are set a week ahead each time Nexpill is used. '
            'Open it to set the next ones.',
        scheduledDate: tz.TZDateTime.from(at, tz.UTC),
        notificationDetails: const NotificationDetails(android: _upkeep),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }

    await _clearGiven(care);
  }

  /// Shows [n] again at its time. [since] is when the snoozed reminder
  /// first fired, so a dose logged at any point after it — including during
  /// the snooze — cancels the repeat.
  Future<void> snooze(PlannedNotification n, {required DateTime since}) async {
    final tag = ReminderTag(since, n.medicationIds);
    await _schedule(_snoozeBase + (_hash(tag.encode()) & 0x0fffffff), n, tag);
  }

  Future<void> _schedule(int id, PlannedNotification n, ReminderTag tag) async {
    await _plugin.zonedSchedule(
      id: id,
      title: n.title,
      body: n.body,
      payload: tag.encode(),
      scheduledDate: tz.TZDateTime.from(n.at, tz.UTC),
      notificationDetails: NotificationDetails(
        android: _details(
            rings: n.rings,
            tag: tag.encode(),
            multiline: n.items.length > 1,
            canSkip: n.canSkip),
      ),
      androidScheduleMode: n.rings
          ? AndroidScheduleMode.alarmClock
          : AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  /// Removes shown notifications whose doses have all been given since.
  Future<void> _clearGiven(CareSnapshot care) async {
    final shown = await _android?.getActiveNotifications() ?? const [];
    for (final n in shown) {
      final tag = ReminderTag.tryParse(n.tag);
      if (n.id != null && tag != null && !tag.stillDue(care)) {
        await _plugin.cancel(id: n.id!, tag: n.tag);
      }
    }
  }

  /// A sample reminder in a few seconds, through the same exact-alarm path
  /// as the real ones, so the whole chain can be checked from Settings.
  Future<void> sendTest() async {
    await _plugin.zonedSchedule(
      id: _testId,
      title: 'Test reminder',
      body: 'Reminders are working. This is how they\'ll look.',
      scheduledDate:
          tz.TZDateTime.from(DateTime.now().add(const Duration(seconds: 5)), tz.UTC),
      // No actions: there's no dose to mark given or snooze.
      notificationDetails: NotificationDetails(
          android: _details(rings: false, withActions: false)),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  /// The reminder whose tap started the app, if one did.
  Future<ReminderTag?> launchTag() async {
    final details = await _plugin.getNotificationAppLaunchDetails();
    if (details?.didNotificationLaunchApp != true) return null;
    return ReminderTag.tryParse(details!.notificationResponse?.payload);
  }

  Future<void> cancelAll() => _plugin.cancelAll();

  static const _refreshNoticeId = 1;
  static const _testId = 2;
  static const _snoozeBase = 0x40000000;

  /// Stable across replans, so a notification that's already showing is
  /// only ever replaced by the same reminder.
  static int _plannedId(PlannedNotification n) =>
      16 + (_hash('${n.patient.id}@${n.at.millisecondsSinceEpoch}') & 0x3fffffe0);
}

/// The details repeated on every scheduled notification, and read back later
/// from the pending list (as its payload) or the shade (as its tag).
@immutable
class ReminderTag {
  const ReminderTag(this.at, this.medicationIds);

  final DateTime at;
  final List<String> medicationIds;

  String encode() => jsonEncode({'at': at.millisecondsSinceEpoch, 'm': medicationIds});

  static ReminderTag? tryParse(String? s) {
    if (s == null) return null;
    try {
      final j = jsonDecode(s) as Map<String, dynamic>;
      return ReminderTag(
        DateTime.fromMillisecondsSinceEpoch(j['at'] as int, isUtc: true),
        (j['m'] as List).cast<String>(),
      );
    } catch (_) {
      return null;
    }
  }

  /// False once every medication here has had a dose logged at or after
  /// the notification's time, or the dose it was about skipped — or has gone.
  bool stillDue(CareSnapshot care) => medicationIds.any((id) {
        final m = care.medication(id);
        if (m == null) return false;
        final latest = latestEntry(id, care.doses);
        if (latest == null) return true;
        // A skip is logged at the time it was due, so ask the engine instead.
        if (latest.skipped) return calculateSchedule(m, care.doses, at).eligibleNow;
        return latest.givenAt.isBefore(at);
      });

  /// What Skip on this reminder skips, as of [now]: for each medication on
  /// it still due, the dose it's due next, by medication id. As-needed ones
  /// and any given or skipped since are left alone.
  Map<String, DateTime> dosesToSkip(CareSnapshot care, DateTime now) {
    final skips = <String, DateTime>{};
    for (final id in medicationIds) {
      final m = care.medication(id);
      if (m == null || m.schedule is PrnSchedule) continue;
      if (!ReminderTag(at, [id]).stillDue(care)) continue;
      final s = calculateSchedule(m, care.doses, now);
      if (!s.finished) skips[id] = s.nextEligibleAt;
    }
    return skips;
  }
}

/// FNV-1a: a hash that stays the same between runs, unlike String.hashCode.
int _hash(String s) {
  var h = 0x811c9dc5;
  for (final c in utf8.encode(s)) {
    h = ((h ^ c) * 0x01000193) & 0xffffffff;
  }
  return h;
}
