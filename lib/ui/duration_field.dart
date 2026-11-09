import 'package:flutter/material.dart';
import 'package:nexpill/ui/language.dart';

/// Days, hours and minutes as three drop-downs, for intervals like 4 h 45 min
/// or 5 days. Minutes go in fives; nobody schedules a dose every 4 h 43 min.
class DurationField extends StatelessWidget {
  const DurationField({
    super.key,
    required this.minutes,
    required this.onChanged,
    this.maxDays = 30,
  });

  final int minutes;
  final ValueChanged<int> onChanged;
  final int maxDays;

  static const _day = 24 * 60;

  @override
  Widget build(BuildContext context) {
    final d = minutes ~/ _day;
    final h = minutes % _day ~/ 60;
    final m = minutes % 60;
    // Keep an unusual existing value (from a backup, say) selectable.
    final dayChoices = {for (var i = 0; i <= maxDays; i++) i, d}.toList()
      ..sort();
    final minuteChoices = {for (var i = 0; i < 60; i += 5) i, m}.toList()
      ..sort();
    void set({int? days, int? hours, int? mins}) =>
        onChanged((days ?? d) * _day + (hours ?? h) * 60 + (mins ?? m));

    Widget box(String label, int value, Iterable<int> choices,
            ValueChanged<int> pick) =>
        Expanded(
          child: DropdownButtonFormField<int>(
            initialValue: value,
            decoration: InputDecoration(labelText: label),
            items: [
              for (final i in choices)
                DropdownMenuItem(value: i, child: Text('$i')),
            ],
            onChanged: (v) => pick(v ?? 0),
          ),
        );

    final l = context.l;
    return Row(
      children: [
        box(l.days, d, dayChoices, (v) => set(days: v)),
        const SizedBox(width: 12),
        box(l.hours, h, [for (var i = 0; i < 24; i++) i], (v) => set(hours: v)),
        const SizedBox(width: 12),
        box(l.minutes, m, minuteChoices, (v) => set(mins: v)),
      ],
    );
  }
}
