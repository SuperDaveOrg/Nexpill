import 'package:flutter/material.dart';

import 'package:nexpill/domain/inventory.dart';
import 'package:nexpill/models/medication.dart';
import 'package:nexpill/ui/language.dart';
import 'package:nexpill/ui/medication_card.dart';

/// Asks how much a new pack adds to [medication]'s supply, saying what's
/// left now. Null if the caregiver backs out.
Future<double?> showRefillDialog(BuildContext context,
        {required Medication medication, required InventoryStatus inventory}) =>
    showDialog<double>(
      context: context,
      builder: (_) => _RefillDialog(medication, inventory),
    );

class _RefillDialog extends StatefulWidget {
  const _RefillDialog(this.medication, this.inventory);

  final Medication medication;
  final InventoryStatus inventory;

  @override
  State<_RefillDialog> createState() => _RefillDialogState();
}

class _RefillDialogState extends State<_RefillDialog> {
  final _amount = TextEditingController();

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  /// The amount entered, if it adds something.
  double? get _parsed {
    final q = double.tryParse(_amount.text.trim().replaceAll(',', '.'));
    return q != null && q > 0 ? q : null;
  }

  void _add() => Navigator.pop(context, _parsed);

  @override
  Widget build(BuildContext context) {
    final m = widget.medication;
    return AlertDialog(
      title: Text(context.l.refillTitle(m.name)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(MedicationCard.leftText(
              context, widget.inventory.remaining!, m.doseUnit)),
          const SizedBox(height: 12),
          TextField(
            controller: _amount,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: context.l.refillAmount,
              suffixText: m.doseUnit,
            ),
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) => _parsed == null ? null : _add(),
          ),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l.cancel)),
        TextButton(
            onPressed: _parsed == null ? null : _add,
            child: Text(context.l.refillAdd)),
      ],
    );
  }
}
