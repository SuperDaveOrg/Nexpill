import 'package:flutter/material.dart';

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

  static const _points = <(IconData, String, String)>[
    (
      Icons.phone_android,
      'It stays on your phone',
      'Everything you log is written to a database on this device. There is '
          'no account and no server. It only goes anywhere else if you move '
          'it yourself, as a backup file or an export.',
    ),
    (
      Icons.cloud_off_outlined,
      'We cannot see it',
      'Nexpill is built without permission to use the internet at all. '
          'Android enforces that, and you can check it in the app\'s '
          'permission list.',
    ),
    (
      Icons.alarm,
      'Reminders come from the phone itself',
      'Each reminder is an alarm this phone holds, so it arrives on time with '
          'no signal, in airplane mode, and after a restart.',
    ),
    (
      Icons.checklist,
      'What the permissions are for',
      'Notifications, for reminders. Exact alarms, so they arrive on the '
          'minute. Starting after a restart, to set them again. Vibration. '
          'That is the whole list.',
    ),
    (
      Icons.volunteer_activism_outlined,
      'Free, for good',
      'Nexpill was written by a caregiver, for caregivers. It will always be '
          'free and open source: no price, no premium tier, no ads.',
    ),
    (
      Icons.code,
      'You can check our work',
      'Nexpill is open source under the MIT licence. Anyone can read exactly '
          'what it does.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('About Nexpill')),
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
          Text('Your records stay with you.', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            'Nexpill keeps track of when each dose was given and when the next '
            'one can be, and reminds you on time. It doesn\'t give medical '
            'advice.',
            style: theme.textTheme.bodyLarge
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 28),
          for (final (icon, title, body) in _points) ...[
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
            'One trade-off worth knowing: there is no cloud copy, so a lost or '
            'wiped phone means lost history. Save a backup file from Settings '
            'now and then, and keep it somewhere other than this phone.',
            style: theme.textTheme.bodySmall,
          ),
          if (version != null) ...[
            const SizedBox(height: 16),
            Text('Version $version', style: theme.textTheme.bodySmall),
          ],
        ],
      ),
    );
  }
}
