import 'package:flutter/material.dart';

import 'package:nexpill/domain/dates.dart';
import 'package:nexpill/domain/forecast.dart';
import 'package:nexpill/domain/wording.dart';
import 'package:nexpill/models/medication.dart';
import 'package:nexpill/models/patient.dart';
import 'package:nexpill/ui/care_store.dart';
import 'package:nexpill/ui/language.dart';
import 'package:nexpill/ui/layout.dart';
import 'package:nexpill/ui/section.dart';

/// What one patient has to take over the coming hours or days, by time and
/// in total: what to load a pill dispenser with.
class ForecastScreen extends StatefulWidget {
  const ForecastScreen({super.key, required this.store, required this.patient});

  final CareStore store;
  final Patient patient;

  @override
  State<ForecastScreen> createState() => _ForecastScreenState();
}

class _ForecastScreenState extends State<ForecastScreen> {
  static const _windows = [
    Duration(hours: 12),
    Duration(hours: 24),
    Duration(days: 3),
    Duration(days: 7),
  ];

  Duration _window = const Duration(hours: 24);

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.store,
      builder: (context, _) {
        final theme = Theme.of(context);
        final now = widget.store.now;
        final forecast = forecastDoses(widget.store.care, widget.patient.id,
            from: now, until: now.add(_window));
        final dueNow = [for (final d in forecast.doses) if (d.dueNow) d];
        final later = [for (final d in forecast.doses) if (!d.dueNow) d];
        final counts = <Medication, int>{};
        for (final d in forecast.doses) {
          counts.update(d.medication, (n) => n + 1, ifAbsent: () => 1);
        }
        final totals = counts.entries.toList()
          ..sort((a, b) => a.key.name.compareTo(b.key.name));

        return Scaffold(
          appBar: AppBar(title: Text(context.l.comingUp)),
          body: ListView(
            padding: readablePadding(context,
                base: const EdgeInsets.only(top: 4, bottom: 32)),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SegmentedButton<Duration>(
                  showSelectedIcon: false,
                  segments: [
                    for (final w in _windows)
                      ButtonSegment(
                        value: w,
                        label: Text(shortDurationText(w.inMinutes),
                            maxLines: 1, softWrap: false),
                      ),
                  ],
                  selected: {_window},
                  onSelectionChanged: (s) => setState(() => _window = s.single),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                child: Text(context.l.comingUpOnTime,
                    style: theme.textTheme.bodySmall),
              ),
              if (forecast.doses.isEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
                  child: Text(context.l.comingUpNothing,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge),
                ),
              if (dueNow.isNotEmpty)
                Section(
                  title: context.l.statusDueNow,
                  children: [_TimeRow(doses: dueNow)],
                ),
              for (final (day, doses) in _byDay(later))
                Section(
                  title: dayHeading(day, now),
                  children: [
                    for (final group in _byTime(doses))
                      _TimeRow(time: clockText(group.first.at), doses: group),
                  ],
                ),
              if (totals.isNotEmpty)
                Section(
                  title: context.l.comingUpTotals,
                  children: [
                    for (final MapEntry(key: m, value: count) in totals)
                      ListTile(
                        title: Text(m.name),
                        subtitle: Text(forecastTotalText(m, count)),
                      ),
                  ],
                ),
              if (forecast.withoutSetTime.isNotEmpty)
                Section(
                  title: context.l.comingUpNoSetTime,
                  children: [
                    for (final m in forecast.withoutSetTime)
                      ListTile(
                        title: Text(m.name),
                        subtitle: Text(m.schedule is PrnSchedule
                            ? scheduleText(m.schedule)
                            : context.l.comingUpFromFirstDose(
                                scheduleText(m.schedule))),
                      ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  /// [doses], in order, split by calendar day on the phone's clock.
  static List<(DateTime, List<ForecastDose>)> _byDay(List<ForecastDose> doses) {
    final days = <DateTime, List<ForecastDose>>{};
    for (final d in doses) {
      days.putIfAbsent(dateOnly(d.at.toLocal()), () => []).add(d);
    }
    return [for (final e in days.entries) (e.key, e.value)];
  }

  /// [doses], in order, split into those due at the same minute.
  static List<List<ForecastDose>> _byTime(List<ForecastDose> doses) {
    final times = <String, List<ForecastDose>>{};
    for (final d in doses) {
      times.putIfAbsent(clockText(d.at), () => []).add(d);
    }
    return times.values.toList();
  }
}

/// One time and everything due at it, like one slot of a pill dispenser.
class _TimeRow extends StatelessWidget {
  const _TimeRow({this.time, required this.doses});

  final String? time;
  final List<ForecastDose> doses;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (time case final time?)
            SizedBox(
              width: 88,
              child: Text(time, style: theme.textTheme.titleSmall),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final (i, d) in doses.indexed) ...[
                  if (i > 0) const SizedBox(height: 10),
                  Text(d.medication.name, style: theme.textTheme.bodyLarge),
                  if (doseLineText(d.medication) case final line
                      when line.isNotEmpty)
                    Text(line,
                        style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
