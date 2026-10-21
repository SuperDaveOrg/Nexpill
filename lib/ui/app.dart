import 'dart:async';

import 'package:flutter/material.dart';

import 'package:nexpill/domain/wording.dart';
import 'package:nexpill/l10n/app_localizations.dart';
import 'package:nexpill/services/notification_service.dart';
import 'package:nexpill/services/preferences.dart';
import 'package:nexpill/ui/care_screen.dart';
import 'package:nexpill/ui/care_store.dart';
import 'package:nexpill/ui/language.dart';
import 'package:nexpill/ui/theme.dart';

/// Holds whose medications are on screen, keeps the clock and the data
/// fresh, and opens the right patient when a reminder is tapped.
class NexpillApp extends StatefulWidget {
  const NexpillApp({
    super.key,
    required this.store,
    required this.reminderTaps,
  });

  final CareStore store;

  /// Reminders tapped while the app runs, or the one that launched it.
  final ValueNotifier<ReminderTag?> reminderTaps;

  @override
  State<NexpillApp> createState() => _NexpillAppState();
}

class _NexpillAppState extends State<NexpillApp> with WidgetsBindingObserver {
  final _navigator = GlobalKey<NavigatorState>();
  /// Null shows everyone, when there's more than one person.
  String? _patientId;
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

  /// Follows the phone's 24-hour setting. Flutter only rereads it at start
  /// and on a configuration change (rotating, dark mode), so a change made
  /// in system settings may wait until then. Reminders say the time too, so
  /// they're replanned.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final use24 = MediaQuery.alwaysUse24HourFormatOf(context);
    if (use24 == use24HourClock) return;
    use24HourClock = use24;
    Preferences.setUse24HourClock(use24);
    widget.store.refresh();
  }

  /// A dose may have been marked given from a reminder while away.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) widget.store.refresh();
  }

  void _select(String patientId) => setState(() => _patientId = patientId);

  void _showEveryone() => setState(() => _patientId = null);

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

  /// Keeps the words outside the widgets — reminders, exports, the
  /// timing phrases — in the language on screen. Reminders say things, so
  /// a change replans them, after this frame.
  void _languageOnScreen(Locale locale) {
    if (locale.languageCode == strings.localeName) return;
    useLanguage(locale);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Preferences.setLanguageInUse(locale.languageCode);
      widget.store.refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: chosenLanguage,
      builder: (context, chosen, _) => MaterialApp(
        title: 'Nexpill',
        debugShowCheckedModeBanner: false,
        navigatorKey: _navigator,
        theme: NexpillTheme.light(),
        darkTheme: NexpillTheme.dark(),
        // Null follows the phone, among the languages Nexpill speaks.
        locale: chosen == null ? null : Locale(chosen),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) {
          _languageOnScreen(Localizations.localeOf(context));
          return child!;
        },
        home: CareScreen(
          store: widget.store,
          patientId: _patientId,
          onSelectPatient: _select,
          onShowEveryone: _showEveryone,
        ),
      ),
    );
  }
}
