# Changelog

What changed in each release of Nexpill, newest first. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and versions follow
the rules in [docs/RELEASING.md](docs/RELEASING.md).

New entries go under **Unreleased** as work lands; `tool/bump_version.sh`
turns that section into the release's own when it's cut.

## [Unreleased]

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
