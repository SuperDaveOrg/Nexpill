import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:nexpill/data/care_repository.dart';
import 'package:nexpill/services/notification_service.dart';
import 'package:nexpill/services/reminder_sync.dart';

/// What every screen reads, and the one way anything gets changed.
///
/// A plain [ChangeNotifier] from Flutter itself, not a state package: it
/// holds the current [CareSnapshot], and [change] runs an edit, replans every
/// reminder, then reloads — so no screen can forget to update the alarms.
class CareStore extends ChangeNotifier {
  CareStore({
    required this.repository,
    required this.notifications,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final CareRepository repository;
  final NotificationService notifications;
  final DateTime Function() _clock;

  CareSnapshot _care =
      const CareSnapshot(patients: [], medications: [], doses: []);
  bool _loaded = false;

  CareSnapshot get care => _care;
  bool get loaded => _loaded;

  /// The moment statuses are worked out for. Moves on with [tick].
  DateTime get now => _now ??= _clock();
  DateTime? _now;

  Future<void> load() async {
    _care = await repository.snapshot();
    _loaded = true;
    _now = _clock();
    notifyListeners();
  }

  /// Moves the clock on, so "due in 5 minutes" counts down on screen, and
  /// rereads the data: a reminder's "Mark given" can log a dose from
  /// another isolate while the app is open.
  Future<void> tick() => load();

  /// Runs [edit], then brings the reminders and every screen up to date.
  Future<T> change<T>(Future<T> Function(CareRepository repo) edit) async {
    final result = await edit(repository);
    await syncReminders(notifications, repository: repository, now: _clock());
    await load();
    return result;
  }

  /// Replans and reloads without changing anything: on app start, and when
  /// coming back to the app, since a reminder's "Mark given" may have
  /// logged a dose while it was away.
  Future<void> refresh() async {
    await syncReminders(notifications, repository: repository, now: _clock());
    await load();
  }
}
