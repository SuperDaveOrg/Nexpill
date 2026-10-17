# Changelog

What changed in each release of Nexpill, newest first. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and versions follow
the rules in [docs/RELEASING.md](docs/RELEASING.md).

New entries go under **Unreleased** as work lands; `tool/bump_version.sh`
turns that section into the release's own when it's cut.

## [Unreleased]

## [0.5.0] - 2026-10-17

### Added
- Skip a dose. When a dose is due, Skip sits next to Give on its card and
  on its reminder; before then, "Skip the 8:00 PM dose" is in the card's ⋮
  menu. The medication carries on as if the dose had been given on time: at
  set times, the next time; every few hours, one interval after the skipped
  dose. Its reminders stop. If it's given after all, Give works as usual and
  the next dose counts from then. The skip is kept in dose history and the
  spreadsheet export; it uses no supply and doesn't count towards a course.
  As-needed medications have nothing to skip. After three skips in a row,
  Skip offers to turn that medication's reminders off; it stays on the list
  to give whenever it's wanted.
- Backups are now format version 3, to carry skipped doses. Older backups
  still restore.

### Changed
- Caring for more than one person, Nexpill now opens on Everyone: each
  person with the medication that needs doing first ("Amoxicillin, Overdue
  25 min") and how many more are due, so a glance says who's next. Tap
  someone to see all their medications; back returns to Everyone instead
  of leaving the app. With just one person, it opens straight on their
  medications as before.

## [0.4.0] - 2026-10-16

### Added
- What each medication is for. Fill in "What it's for" when adding or
  editing one ("blood pressure", "pain after surgery") and it shows on the
  medication's card under its name, in its reminders, and in the printable
  summary. It's optional, and it's kept in backups.

## [0.3.0] - 2026-10-11

### Added
- A course with an end. Under "How long" when adding or editing a
  medication, choose a last day ("until the 14th") or a number of doses
  ("10 doses"). Its card shows what's left, and when the course is over its
  reminders stop by themselves and it moves to the bottom of the list,
  history kept. Open it there to make the course longer.
- Backups are now format version 2, to carry courses. Older backups still
  restore; an older Nexpill refuses a new backup and asks to be updated,
  rather than restoring it without its courses.

### Changed
- A taper now finishes when its last step ends: from midnight on the end
  date it stops reminding and moves to the bottom of the list as "Taper
  finished", instead of showing the dose as overdue. A taper whose last
  step has no end date carries on as before.
- Saved summaries and dose histories are named the same way, e.g.
  `nexpill-alex-summary-2026-06-10.txt` and `nexpill-alex-doses-2026-06-10.csv`.

### Fixed
- Times follow the phone's 24-hour setting, on screen and in reminders.
  They always read "7:15 PM" before.
- The "Log dose" button no longer sits partly under a 3-button navigation
  bar, where a tap on it landed on the bar instead.
- Correcting a dose whose "Given by" was left blank no longer fills in
  the last name used.
- After a restore, Settings shows the restored people straight away. It
  showed none, and no summary, until it was reopened.
- Correcting a dose now saves exactly what you enter. Before, clearing
  "Given by" or the notes, or setting the dose back to the usual one, kept
  the original entry's value.

## [0.2.2] - 2026-10-02

### Fixed
- The "logged" and "stopped" messages with an Undo button now go away by
  themselves after a few seconds. They stayed on screen until you tapped
  Undo, covering the buttons at the bottom of the next screen.

## [0.2.1] - 2026-09-29

### Changed
- Smaller downloads from F-Droid: it now offers an APK built for your phone's
  processor, about a third of the size of the one that runs on any phone.
  The website still offers that universal APK, and each release's APKs are
  all on its GitHub release page.

## [0.2.0] - 2026-09-29

### Added
- Settings → About has links to Nexpill's website and its feedback form. They
  open in your browser; Nexpill itself still has no internet permission.

### Changed
- Nexpill is now licensed under the GNU General Public License, version 3
  or later. Version 0.1.0 remains available under the MIT licence.

## [0.1.0] - 2026-09-27

### Changed
- Rebuilt as a native Android app in Flutter, replacing the web app, so
  reminders can be real alarms scheduled by the phone. The optional cloud
  account, sync and emailed reminders are gone: everything stays on the
  phone.
- A dose given for a fixed-time medication now counts: given at 08:05 for
  the 08:00 slot, it's next due at the following slot instead of showing
  overdue until then. Each dose counts for the slot nearest to when it was
  given.
- Taper steps begin at midnight on the phone's clock, not UTC midnight.
- A taper dose long overdue is marked missed, as interval doses already were.

- A new medication starts with reminders on (off for as-needed ones), with
  no early heads-up; settings are always saved as shown.
- Overdue reminders stop after six repeats, rather than for as long as the
  app was open.

### Added
- The medication timing engine, ported from the web app and checked against
  its answers for over 2,000 scenarios.
- Reminders as exact alarms held by the phone, which arrive on the minute
  with no network, including "ring like an alarm" for chosen medications.
  Mark a dose given or snooze straight from the notification.
- Backups to a documented file, saved wherever you choose; restore checks
  the whole file before replacing anything.
- Dose history as a spreadsheet (CSV) and a printable summary per patient.
- New screens throughout, in the SuperDaveLab look shared with LedgerDock
  and LedgerSprout: medications sorted by what needs doing first, a warning
  before giving a dose early, undo, dose history by day, and a test reminder
  in Settings.
- A new site at nexpill.superdavelab.com, replacing the web app, with
  downloads, screenshots and where your data lives.
- A new logo in the family style: a pill clock, with a capsule as the hand
  of a clock face.
