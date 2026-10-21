import 'package:flutter/material.dart';

import 'package:nexpill/l10n/app_localizations.dart';
import 'package:nexpill/ui/language.dart';
import 'package:nexpill/ui/layout.dart';

/// Explains, in plain language, where the data lives and why Nexpill is
/// free.
///
/// A statement about *our* obligations — what we don't collect and can't
/// reach — never a warning. Taking medication is ordinary; see
/// docs/privacy.md.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key, this.version});

  final String? version;

  static List<(IconData, String, String)> _points(AppLocalizations l) => [
        (Icons.phone_android, l.aboutStaysTitle, l.aboutStaysBody),
        (Icons.cloud_off_outlined, l.aboutCannotSeeTitle, l.aboutCannotSeeBody),
        (Icons.alarm, l.aboutRemindersTitle, l.aboutRemindersBody),
        (Icons.checklist, l.aboutPermissionsTitle, l.aboutPermissionsBody),
        (Icons.volunteer_activism_outlined, l.aboutFreeTitle, l.aboutFreeBody),
        (Icons.code, l.aboutCheckTitle, l.aboutCheckBody),
      ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = context.l;
    return Scaffold(
      appBar: AppBar(title: Text(l.aboutNexpill)),
      body: ListView(
        padding: readablePadding(context,
            base: const EdgeInsets.fromLTRB(20, 8, 20, 32)),
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 20),
              child: Image.asset('assets/brand/nexpill_logo_512.png',
                  width: 96, height: 96, semanticLabel: 'Nexpill'),
            ),
          ),
          Text(l.aboutHeadline, style: theme.textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            l.aboutIntro,
            style: theme.textTheme.bodyLarge
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 28),
          for (final (icon, title, body) in _points(l)) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: theme.colorScheme.primary),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: theme.textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text(body, style: theme.textTheme.bodyMedium),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
          const Divider(height: 32),
          Text(
            l.aboutTradeOff,
            style: theme.textTheme.bodySmall,
          ),
          if (version != null) ...[
            const SizedBox(height: 16),
            Text(l.versionNumber(version!), style: theme.textTheme.bodySmall),
          ],
        ],
      ),
    );
  }
}
