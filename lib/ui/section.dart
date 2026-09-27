import 'package:flutter/material.dart';

/// A titled group of rows on a card — how Settings and similar lists are
/// laid out, so related things read as one block instead of a long list.
class Section extends StatelessWidget {
  const Section({super.key, this.title, required this.children});

  final String? title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = this.title;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 22, 8, 8),
              child: Text(
                title.toUpperCase(),
                style: theme.textTheme.labelSmall
                    ?.copyWith(color: theme.colorScheme.primary),
              ),
            )
          else
            const SizedBox(height: 16),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (var i = 0; i < children.length; i++) ...[
                  if (i > 0) const Divider(indent: 16, endIndent: 16),
                  children[i],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
