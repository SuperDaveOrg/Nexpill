import 'package:flutter/material.dart';

import 'package:nexpill/domain/inventory.dart';
import 'package:nexpill/domain/status.dart';
import 'package:nexpill/domain/wording.dart';
import 'package:nexpill/models/medication.dart';
import 'package:nexpill/ui/theme.dart';

enum CardAction { edit, history, stop, resume }

/// One medication at a glance: what it is, the one thing to know about it
/// right now, and a button to give it. Tapping the card edits it.
class MedicationCard extends StatelessWidget {
  const MedicationCard({
    super.key,
    required this.medication,
    required this.status,
    required this.inventory,
    required this.now,
    required this.onGive,
    required this.onAction,
    this.onSkip,
    this.lastGivenBy,
    this.course,
  });

  final Medication medication;
  final MedicationStatus status;
  final InventoryStatus inventory;
  final DateTime now;
  final String? lastGivenBy;

  /// How much of a course is left, e.g. "3 doses left"; null if none.
  final String? course;
  final VoidCallback onGive;

  /// Skips the dose due now, or the next one; null for as-needed. A button
  /// while it's due, and in the menu before then.
  final VoidCallback? onSkip;
  final ValueChanged<CardAction> onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = StatusColors.of(context);
    final m = medication;
    final (headline, detail) = cardText(status, m, now);
    final accent = switch (status.label) {
      MedicationStatusLabel.missed ||
      MedicationStatusLabel.overdue => colors.late,
      MedicationStatusLabel.dueSoon => colors.soon,
      MedicationStatusLabel.eligibleNow ||
      MedicationStatusLabel.availablePrn => colors.ok,
      _ => theme.colorScheme.onSurface,
    };
    final last = status.schedule.lastGivenAt;
    final due = status.schedule.eligibleNow;
    final next = status.schedule.nextEligibleAt;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => onAction(CardAction.edit),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 10, 8, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: m.name,
                              style: theme.textTheme.titleLarge,
                            ),
                            if (m.strengthText != null)
                              TextSpan(
                                text: '  ${m.strengthText}',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  PopupMenuButton<CardAction>(
                    tooltip: 'More for ${m.name}',
                    onSelected: onAction,
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                        value: CardAction.edit,
                        child: Text('Edit'),
                      ),
                      const PopupMenuItem(
                        value: CardAction.history,
                        child: Text('Dose history'),
                      ),
                      if (onSkip != null && !due)
                        PopupMenuItem(
                          onTap: onSkip,
                          child: Text('Skip the ${clockText(next)} dose'),
                        ),
                      const PopupMenuItem(
                        value: CardAction.stop,
                        child: Text('Stop taking'),
                      ),
                    ],
                  ),
                ],
              ),
              if (m.purpose != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(m.purpose!, style: theme.textTheme.bodyMedium),
                ),
              Text(
                [m.defaultDoseText, scheduleShortText(m.schedule, now), ?course]
                    .join(' · '),
                style: theme.textTheme.bodySmall,
              ),
              if (m.instructions != null) ...[
                const SizedBox(height: 4),
                Text(m.instructions!, style: theme.textTheme.bodySmall),
              ],
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            headline,
                            style: NexpillTheme.font(
                              NexpillTheme.serif,
                              24,
                              600,
                              height: 1.15,
                              color: accent,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(detail, style: theme.textTheme.bodyMedium),
                          if (last != null)
                            Text(
                              'Last given ${whenText(last, now)}'
                              '${lastGivenBy == null ? '' : ' by $lastGivenBy'}',
                              style: theme.textTheme.bodySmall,
                            ),
                          if (inventory.configured)
                            Text(
                              _supplyText(inventory, m.doseUnit),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: switch (inventory.level) {
                                  InventoryLevel.out => colors.late,
                                  InventoryLevel.low => colors.soon,
                                  _ => null,
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (onSkip != null && due) ...[
                      TextButton(onPressed: onSkip, child: const Text('Skip')),
                      const SizedBox(width: 4),
                    ],
                    FilledButton(onPressed: onGive, child: const Text('Give')),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _supplyText(InventoryStatus i, String? unit) {
    final left =
        '${quantityText(i.remaining! < 0 ? 0 : i.remaining!)}'
        '${unit == null ? '' : ' $unit'} left';
    return switch (i.level) {
      InventoryLevel.out => 'None left: time to refill',
      InventoryLevel.low => '$left: running low',
      _ => left,
    };
  }
}
