# Changelog

What changed in each release of Nexpill, newest first. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and versions follow
the rules in [docs/RELEASING.md](docs/RELEASING.md).

New entries go under **Unreleased** as work lands; `tool/bump_version.sh`
turns that section into the release's own when it's cut.

## [Unreleased]

### Added
- A course with an end. Under "How long" when adding or editing a
  medication, choose a last day ("until the 14th") or a number of doses
  ("10 doses"). Its card shows what's left, and when the course is over its
  reminders stop by themselves and it moves to the bottom of the list,
  history kept. Open it there to make the course longer.

### Changed
- A taper now finishes when its last step ends: from midnight on the end
  date it stops reminding and moves to the bottom of the list as "Taper
  finished", instead of showing the dose as overdue. A taper whose last
  step has no end date carries on as before.
- Saved summaries and dose histories are named the same way, e.g.
  `nexpill-alex-summary-2026-06-10.txt` and `nexpill-alex-doses-2026-06-10.csv`.

### Fixed
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
