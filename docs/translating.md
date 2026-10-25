# Translating Nexpill

Nexpill speaks English, German, Spanish, French, Italian, Portuguese
(Portugal) and Russian. This is how the words are kept, how to add a language, and what a
translation has to get right.

## Where the words are

Every word the app shows is in `lib/l10n/app_<language>.arb`: plain JSON,
one message per key. `app_en.arb` is the template; each other file
translates every one of its keys. Flutter's `gen-l10n` (set up in
`l10n.yaml`, run by any `flutter` build or `flutter gen-l10n`) turns them
into `AppLocalizations` in `lib/l10n/`. The generated `.dart` files are
committed, so a fresh checkout analyzes without a build first.

Two ways in, both the same words:

- **Screens** use `context.l` (from `lib/ui/language.dart`), so they rebuild
  when the language changes.
- **Everything outside the widgets** — the timing phrases in
  `lib/domain/wording.dart`, reminders, exports, backup errors — uses the
  `strings` global in `wording.dart`. Like `use24HourClock`, the app sets
  it as the language on screen changes, and the reminder isolate from the
  copy kept in Preferences. Reminders contain words, so a language change
  replans them.

The language follows the phone unless one is picked in Settings → Language.
On Android 13 and later it can also be set per app in the phone's settings,
from `android/app/src/main/res/xml/locales_config.xml`.

Not translated, on purpose: the brand name, the backup file's field names
(they're the public format), file names, the debug-only Development section,
and anything the user typed — medication names, doses, notes.

## Adding a language

1. Copy `lib/l10n/app_en.arb` to `app_<code>.arb`, set `"@@locale"`, delete
   the `@` entries (only the template needs them), and translate every
   message.
2. Add the language, by its own name, to `languageNames` in
   `lib/ui/language.dart`.
3. Add it to `android/app/src/main/res/xml/locales_config.xml`.
4. `flutter test test/l10n`: it fails if a message is missing, has a
   placeholder the English doesn't, or the language is missing from either
   list.
5. Have a native speaker check it in the running app before it ships (see
   below), and say so in the CHANGELOG.

## Getting it right

**A mistranslated status is a safety problem**, not a typo. A caregiver
reading "due" where the app means "can be given", or "missed" where it means
"overdue", may give a dose at the wrong time. The words that must be exact:

| English | Means |
|---|---|
| due now | the dose should be given now |
| due soon / due in 8 min | not yet; it will be due shortly |
| next dose at… / too early | not yet; giving it now would be early |
| can be given (as-needed medications) | allowed, never required |
| overdue | it was due and hasn't been given |
| missed | so late the next one is nearly due |
| skip | deliberately not given; the schedule carries on |
| correction | replaces a mistaken entry, which stays in history |

Other rules:

- **Whole sentences.** Each message is a complete phrase with placeholders
  (`{medication}`, `{time}`), never pieces glued together, because word
  order differs. Keep every placeholder.
- **Plurals** use ICU syntax: `{count, plural, =1{…} other{…}}`. Languages
  with more forms add them (`one`, `few`, `many`; Russian needs all three).
- **Time words.** `whenToday`, `whenTomorrow` and the like become part of
  bigger sentences ("since {when}", "was due {when}"). Spanish words today as
  "hoy a las 4:28" so every one of those reads correctly; check yours read
  well in all of them.
- **Plain and calm**, as in [privacy.md](privacy.md): a tired caregiver at
  3 am. No medical advice, in any language.
- **"You" the way phone apps say it** in that language, consistently:
  *tú* in Spanish, *tu* in Italian, *vous* in French, *вы* in Russian, the
  impersonal style usual in European Portuguese, and in German whatever
  Android's own German uses.
- **Names don't decline.** Medication and person names are typed by the
  user, so a language with cases (Russian) uses constructions like
  "{medication}: …" that never need them inflected.

## Status

| Language | State |
|---|---|
| English | The source. |
| German | First draft, written with an AI assistant. **Needs review by a native speaker before release**, like every language below. |
| Spanish | First draft, written with an AI assistant. **Needs review by a native speaker before release**, above all the statuses in the table above. |
| French | The same. |
| Italian | The same. |
| Portuguese (Portugal) | The same. The file is plain `pt`, so Brazilian phones get it too; Brazilian Portuguese would be its own `app_pt_BR.arb`. |
| Russian | The same. Asked for by a user. |
