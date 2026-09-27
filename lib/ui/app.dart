import 'dart:async';

import 'package:flutter/material.dart';

import 'package:nexpill/services/notification_service.dart';
import 'package:nexpill/services/preferences.dart';
import 'package:nexpill/ui/care_screen.dart';
import 'package:nexpill/ui/care_store.dart';
import 'package:nexpill/ui/theme.dart';

/// Holds whose medications are on screen, keeps the clock and the data
/// fresh, and opens the right patient when a reminder is tapped.
class NexpillApp extends StatefulWidget {
  const NexpillApp({
    super.key,
    required this.store,
    required this.reminderTaps,
    this.initialPatientId,
  });

  final CareStore store;

  /// Reminders tapped while the app runs, or the one that launched it.
  final ValueNotifier<ReminderTag?> reminderTaps;
  final String? initialPatientId;

  @override
  State<NexpillApp> createState() => _NexpillAppState();
}

class _NexpillAppState extends State<NexpillApp> with WidgetsBindingObserver {
  final _navigator = GlobalKey<NavigatorState>();
  late String? _patientId = widget.initialPatientId;
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Often enough that "due in 8 min" counts down, rarely enough to cost
    // nothing.
    _tick = Timer.periodic(const Duration(seconds: 20), (_) => widget.store.tick());
    widget.reminderTaps.addListener(_openTapped);
    _openTapped();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.reminderTaps.removeListener(_openTapped);
    _tick?.cancel();
    super.dispose();
  }

  /// A dose may have been marked given from a reminder while away.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) widget.store.refresh();
  }

  void _select(String patientId) {
    setState(() => _patientId = patientId);
    Preferences.setLastPatient(patientId);
  }

  void _openTapped() {
    final tag = widget.reminderTaps.value;
    if (tag == null) return;
    widget.reminderTaps.value = null;
    final care = widget.store.care;
    for (final id in tag.medicationIds) {
      final m = care.medication(id);
      if (m != null) {
        _select(m.patientId);
        break;
      }
    }
    _navigator.currentState?.popUntil((r) => r.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nexpill',
      debugShowCheckedModeBanner: false,
      navigatorKey: _navigator,
      theme: NexpillTheme.light(),
      darkTheme: NexpillTheme.dark(),
      home: CareScreen(
        store: widget.store,
        patientId: _patientId,
        onSelectPatient: _select,
      ),
    );
  }
}
