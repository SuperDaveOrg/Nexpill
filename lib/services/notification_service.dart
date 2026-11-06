import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import 'package:nexpill/models/care_snapshot.dart';
import 'package:nexpill/domain/dose_history.dart';
import 'package:nexpill/domain/reminder_planner.dart';
import 'package:nexpill/domain/scheduling.dart';
import 'package:nexpill/domain/wording.dart';
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
    int snoozeMinutes = defaultSnoozeMinutes,
  }) {
    final style = multiline ? const BigTextStyleInformation('') : null;
    final actions = withActions
        ? [_given, if (canSkip) _skip, _snooze(snoozeMinutes)]
        : null;
    if (rings) {
      return AndroidNotificationDetails(
        'alarms',
        strings.channelAlarms,
        channelDescription: strings.channelAlarmsDescription,
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
      strings.channelReminders,
      channelDescription: strings.channelRemindersDescription,
      importance: Importance.high,
      priority: Priority.high,
      category: AndroidNotificationCategory.reminder,
      icon: _icon,
      actions: actions,
      styleInformation: style,
      tag: tag,
    );
  }

  static AndroidNotificationDetails get _upkeep => AndroidNotificationDetails(
        'upkeep',
        strings.channelUpkeep,
        channelDescription: strings.channelUpkeepDescription,
        icon: _icon,
      );

  static const _icon = 'ic_stat_nexpill';

  // In the language on screen when the reminder was planned.
  static AndroidNotificationAction get _given =>
      AndroidNotificationAction(actionGiven, strings.actionMarkGiven);
  static AndroidNotificationAction get _skip =>
      AndroidNotificationAction(actionSkip, strings.actionSkip);
  static AndroidNotificationAction _snooze(int minutes) =>
      AndroidNotificationAction(actionSnooze, strings.actionSnooze(minutes));

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
      final tag = ReminderTag(n.at, n.medicationIds, snoozeMinutes: n.snoozeMinutes);
      await _schedule(_plannedId(n), n, tag);
    }

    if (plan.refreshNoticeAt case final at?) {
      await _plugin.zonedSchedule(
        id: _refreshNoticeId,
        title: strings.upkeepTitle,
        body: strings.upkeepBody,
        scheduledDate: tz.TZDateTime.from(at, tz.UTC),
        notificationDetails: NotificationDetails(android: _upkeep),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }

    await _clearGiven(care);
  }

  /// When each medication's pending snooze ends, for the planner to hold
  /// its repeats back. Android's list of pending alarms is the record of
  /// them, and it outlasts a restart of the app or the phone.
  Future<Map<String, DateTime>> snoozedUntil(CareSnapshot care) async {
    final pending = await _plugin.pendingNotificationRequests();
    return snoozeEnds(
      [
        for (final p in pending)
          if (p.id >= _snoozeBase) ?ReminderTag.tryParse(p.payload),
      ],
      care,
    );
  }

  /// Shows [n] again at its time, instead of any other reminder about the
  /// same medications, so one tap on Snooze quiets all of them. [since] is
  /// when the snoozed reminder first fired, so a dose logged at any point
  /// after it — including during the snooze — cancels the repeat.
  Future<void> snooze(PlannedNotification n, {required DateTime since}) async {
    bool replaced(ReminderTag tag) =>
        tag.medicationIds.every(n.medicationIds.contains);

    for (final pending in await _plugin.pendingNotificationRequests()) {
      final tag = ReminderTag.tryParse(pending.payload);
      if (pending.id >= _snoozeBase && tag != null && replaced(tag)) {
        await _plugin.cancel(id: pending.id);
      }
    }
    for (final shown in await _android?.getActiveNotifications() ?? const []) {
      final tag = ReminderTag.tryParse(shown.tag);
      if (shown.id != null && tag != null && replaced(tag)) {
        await _plugin.cancel(id: shown.id!, tag: shown.tag);
      }
    }

    final tag = ReminderTag(since, n.medicationIds,
        snoozeMinutes: n.snoozeMinutes, until: n.at);
    final id = ReminderTag(since, n.medicationIds).encode();
    await _schedule(_snoozeBase + (_hash(id) & 0x0fffffff), n, tag);
  }

  Future<void> _schedule(int id, PlannedNotification n, ReminderTag tag) async {
    await _plugin.zonedSchedule(
      id: id,
      title: n.title,
      body: n.body,
      payload: tag.encode(),
      scheduledDate: tz.TZDateTime.from(alarmTime(n.at, DateTime.now()), tz.UTC),
      notificationDetails: NotificationDetails(
        android: _details(
            rings: n.rings,
            tag: tag.encode(),
            multiline: n.items.length > 1,
            canSkip: n.canSkip,
            snoozeMinutes: tag.snoozeMinutes),
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
      title: strings.testReminderTitle,
      body: strings.testReminderBody,
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
  const ReminderTag(
    this.at,
    this.medicationIds, {
    this.snoozeMinutes = defaultSnoozeMinutes,
    this.until,
  });

  final DateTime at;
  final List<String> medicationIds;

  /// What the Snooze button on this notification says, and so what it does.
  final int snoozeMinutes;

  /// When this snooze ends, if it is one.
  final DateTime? until;

  String encode() => jsonEncode({
        'at': at.millisecondsSinceEpoch,
        'm': medicationIds,
        's': snoozeMinutes,
        if (until != null) 'u': until!.millisecondsSinceEpoch,
      });

  static ReminderTag? tryParse(String? s) {
    if (s == null) return null;
    try {
      final j = jsonDecode(s) as Map<String, dynamic>;
      return ReminderTag(
        DateTime.fromMillisecondsSinceEpoch(j['at'] as int, isUtc: true),
        (j['m'] as List).cast<String>(),
        // Absent on anything scheduled before Snooze followed the repeat
        // setting, whose button says 5 minutes.
        snoozeMinutes: j['s'] as int? ?? defaultSnoozeMinutes,
        until: switch (j['u']) {
          final int ms => DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true),
          _ => null,
        },
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
        if (latest.skipped) {
          final s = calculateSchedule(m, care.doses, at);
          return !s.finished && s.eligibleNow;
        }
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

/// When to set the alarm for a reminder due at [at], as of [now].
///
/// Replanning cancels every alarm and then sets them again, which takes
/// seconds, so a reminder can come due while it's underway. Android has no
/// alarm for it by then, and the plugin refuses a time in the past: that would
/// lose this reminder and, by stopping the replan, all those after it. So one
/// whose time has just gone rings straight away.
DateTime alarmTime(DateTime at, DateTime now) {
  final soonest = now.add(const Duration(seconds: 1));
  return at.isAfter(soonest) ? at : soonest;
}

/// When each medication's snooze ends, from [snoozes], the tags of those
/// still pending. A medication whose dose has been given or skipped since
/// isn't held back, and if two snoozes cover one, the later end wins.
Map<String, DateTime> snoozeEnds(Iterable<ReminderTag> snoozes, CareSnapshot care) {
  final ends = <String, DateTime>{};
  for (final tag in snoozes) {
    final until = tag.until;
    if (until == null) continue;
    for (final id in tag.medicationIds) {
      if (!ReminderTag(tag.at, [id]).stillDue(care)) continue;
      final end = ends[id];
      if (end == null || until.isAfter(end)) ends[id] = until;
    }
  }
  return ends;
}

/// FNV-1a: a hash that stays the same between runs, unlike String.hashCode.
int _hash(String s) {
  var h = 0x811c9dc5;
  for (final c in utf8.encode(s)) {
    h = ((h ^ c) * 0x01000193) & 0xffffffff;
  }
  return h;
}
