import 'package:flutter/widgets.dart';

import 'package:nexpill/l10n/app_localizations.dart';

/// The language picked in Settings, as a language code; null follows the
/// phone. Loaded from Preferences at start.
final chosenLanguage = ValueNotifier<String?>(null);

/// Each language Nexpill speaks, by its own name, as Settings lists it.
/// Never translated: someone looking for their language reads it in theirs.
const languageNames = {
  'de': 'Deutsch',
  'en': 'English',
  'es': 'Español',
  'fr': 'Français',
  'it': 'Italiano',
  // European Portuguese; a Brazilian phone gets it too, rather than English.
  'pt': 'Português (Portugal)',
  'ru': 'Русский',
};

/// The language Nexpill will use: [chosen], or the first of the phone's
/// [preferred] languages that it speaks, or English.
Locale resolveLanguage(String? chosen, List<Locale> preferred) {
  if (chosen != null) return Locale(chosen);
  final spoken = {for (final l in AppLocalizations.supportedLocales) l.languageCode};
  for (final l in preferred) {
    if (spoken.contains(l.languageCode)) return Locale(l.languageCode);
  }
  return const Locale('en');
}

extension Strings on BuildContext {
  /// The app's words, in the language on screen.
  AppLocalizations get l => AppLocalizations.of(this);
}
