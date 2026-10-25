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

## Translating on Weblate

The easiest way to help is [Hosted Weblate](https://hosted.weblate.org/projects/nexpill/),
a web editor that needs no Git or Flutter. Sign in, pick a language, and
fix what reads wrongly. Where a string is ambiguous, a note under it says
which screen it's on and what it must mean; the `description` entries in
`app_en.arb` are those notes, so add one whenever a new string could be
misread. Weblate checks placeholders and plural forms as you type (ICU
MessageFormat), and translators can comment on a string, or on the English.

| Component | Files | What it is |
|---|---|---|
| App | `lib/l10n/app_*.arb` | Every word in the app. |
| Store listing | `fastlane/metadata/android/*/` | The title and descriptions F-Droid shows. |

**How changes come back.** Weblate commits each translator's work under
their own name and opens a pull request against `main` (one per
component, updated until it's merged). To merge one:

1. CI runs the usual checks; `flutter test test/l10n` is the one that
   matters here.
2. If it adds a language, do steps 2 and 3 below first; the test fails
   until the language is in both lists. Merge a new language once it's
   complete: `gen-l10n` quietly fills gaps with English, which is exactly
   what the test is there to refuse.
3. Merge with a merge commit, not a squash. Weblate matches its commits
   against `main`, and a squash leaves it to rebase.
4. Run `flutter gen-l10n`, which rewrites the generated `.dart` files in
   `lib/l10n/`, and commit them.

Don't edit a translated `.arb` on `main` while Weblate has unmerged
changes; lock the component on Weblate first (Manage → Repository
maintenance), or the two conflict. The English still changes here, in
`app_en.arb`: Weblate picks it up on the next push to `main` and marks the
affected translations for attention.

**Weblate settings**, should they ever need recreating. Project
`nexpill`, licence GPL-3.0-or-later, source language English, source
repository `https://github.com/SuperDaveOrg/Nexpill.git` on branch `main`,
pushed through the Hosted Weblate GitHub app (or the *GitHub pull request*
VCS with an empty push URL, which uses a fork).

| | App | Store listing |
|---|---|---|
| File format | ARB file | App store metadata files |
| File mask | `lib/l10n/app_*.arb` | `fastlane/metadata/android/*` |
| Monolingual base language file | `lib/l10n/app_en.arb` | `fastlane/metadata/android/en-US` |
| Template for new translations | empty | `fastlane/metadata/android/en-US` |
| Language code style | default (`pt_BR`, as Flutter names files) | BCP with hyphen (`pt-PT`, as F-Droid names directories) |
| Key filter | none | `^(?!changelogs/)`, so release notes stay English |
| Edit base file, Manage strings | off | off |

The ARB format turns on Weblate's ICU MessageFormat check by itself, which
covers placeholders and plural forms; no extra translation flags are
needed.

## Adding a language

1. On Weblate, open the App component and choose *Start new translation*.
   It creates `lib/l10n/app_<code>.arb` and the usual pull request. (By
   hand instead: copy `app_en.arb` to `app_<code>.arb`, set `"@@locale"`,
   delete the `@` entries, and translate every message.)
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
| German | First draft, written with an AI assistant. **Needs review by a native speaker before release**, like every language below; the place to do it is [Weblate](https://hosted.weblate.org/projects/nexpill/). |
| Spanish | First draft, written with an AI assistant. **Needs review by a native speaker before release**, above all the statuses in the table above. |
| French | The same. |
| Italian | The same. |
| Portuguese (Portugal) | The same. The file is plain `pt`, so Brazilian phones get it too; Brazilian Portuguese would be its own `app_pt_BR.arb`. |
| Russian | The same. Asked for by a user. |
