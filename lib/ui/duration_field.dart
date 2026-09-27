import 'package:flutter/material.dart';

/// Hours and minutes as two drop-downs, for intervals like 4 h 45 min.
/// Minutes go in fives; nobody schedules a dose every 4 h 43 min.
class DurationField extends StatelessWidget {
  const DurationField({
    super.key,
    required this.minutes,
    required this.onChanged,
    this.maxHours = 72,
  });

  final int minutes;
  final ValueChanged<int> onChanged;
  final int maxHours;

  @override
  Widget build(BuildContext context) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    // Keep an unusual existing value (from a backup, say) selectable.
    final minuteChoices = {for (var i = 0; i < 60; i += 5) i, m}.toList()..sort();
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<int>(
            initialValue: h.clamp(0, maxHours),
            decoration: const InputDecoration(labelText: 'Hours'),
            items: [
              for (var i = 0; i <= maxHours; i++)
                DropdownMenuItem(value: i, child: Text('$i')),
            ],
            onChanged: (v) => onChanged((v ?? 0) * 60 + m),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: DropdownButtonFormField<int>(
            initialValue: m,
            decoration: const InputDecoration(labelText: 'Minutes'),
            items: [
              for (final i in minuteChoices)
                DropdownMenuItem(value: i, child: Text('$i')),
            ],
            onChanged: (v) => onChanged(h * 60 + (v ?? 0)),
          ),
        ),
      ],
    );
  }
}
