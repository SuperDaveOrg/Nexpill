# Porting from the PWA

Nexpill started as a React progressive web app. It is being rebuilt as a
Flutter Android app because a web app can't schedule alarms with the operating
system: reminders fired only while the browser was awake. This file tracks the
port and records every place the new app deliberately behaves differently from
the old one. Delete it once the port is done and the open items below are
settled.

The PWA's last state is the final React commit in this repository's history
(and, locally, `../nexpill_bak/`).

## What was left behind

There were no users, so nothing is migrated.

- **The server and account mode** — auth, cloud sync, the web-push, email
  and SMS reminder relay, sessions, emailed exports. Their main reason to
  exist was reminder reliability, which native alarms now provide; the other
  was sync, which conflicts with "your data stays on your phone". See
  [privacy.md](privacy.md) and, for sharing between caregivers, the
  [roadmap](roadmap.md).
- **The service worker and PWA install flow**, and with them the "update
  available" roadmap item.
- **The in-app alarm** (Web Audio + vibration while the page was open) and
  "Prevent sleep". Replaced by a native alarm-style notification in step 3.
- **The PWA backup format.** Nexpill's own is designed fresh in step 2.

## Steps

| # | Step | State |
|---|---|---|
| 1 | Scaffold from Ebb's structure; port the timing engine and its tests; check it against the PWA | **Done** |
| 2 | Storage (sqflite), backup format, CSV and summary exports | **Done** |
| 3 | Reminder planner and exact alarms | **Done**; needs time on real phones |
| 4 | Screens: Care, Meds, History, Patients, Settings | **Done** |
| — | Real-phone testing of reminders | Next |
| 5 | Icon (done: `assets/brand/`), store metadata, site and GitHub release scripts, F-Droid submission | |

### 1. Engine — done

`lib/domain/` holds the port of the PWA's `src/engine/` and
`src/domain/dateParsing.ts`: `calculateSchedule` (was
`calculateMedicationSchedule`), `computeMedicationStatus` (was in
`contract.ts`, which described itself as reference-only but was what every
medication card used), and `computeInventoryStatus`.

It is checked two ways:

- `test/domain/engine_golden_test.dart` compares the Dart engine with 2,114
  answers recorded from the TypeScript engine — interval, as-needed,
  fixed-time and taper schedules, corrections, ties, boundaries to the
  minute and second, inventory. The answers were generated in five time zones
  and are identical in all of them, and the Dart test passes in any zone. Each
  of several deliberately introduced porting mistakes fails dozens to hundreds
  of cases. How to regenerate: `tool/engine_golden/generate.sh`. Cases whose
  answer was changed on purpose since (see "Changed from the PWA engine")
  are skipped or adjusted in the test, by item number.
- The PWA's hand-written tests are ported as readable Dart tests beside it.

Differences in shape, not behaviour:

- Models hold `DateTime`s and parsed `ClockTime`s rather than strings, so an
  unparseable timestamp can't reach the engine. The PWA engine skipped such
  doses; in Nexpill, backup import refuses them.
- A correction is any dose with `supersedesId` set; the PWA's separate
  `corrected` flag is gone.
- `buildMedicationTiming` and `getDueStatus` weren't ported: nothing outside
  their tests used them.
- The reminder rules (`src/reminders/`) weren't ported here. They answered
  "what's due now?" for a page that polled every minute; alarms need "what
  will be due, and when?", which is step 3's planner.

### 2. Storage — done

- `lib/data/database.dart` (schema v1) and `care_repository.dart`, as in
  Ebb. IDs are random UUIDs: corrections refer to them, and any future
  hand-over between phones needs IDs that can't collide. Dose times are
  stored as UTC milliseconds.
- Reminder settings are stored explicitly, with no "unset" state (item 3
  below).
- The backup format is documented in [backup-format.md](backup-format.md):
  versioned, nested (patients → medications → doses) so nothing can dangle,
  instants always with an offset. Import checks the whole file first —
  duplicate ids, corrections that point outside their medication or go round
  in a circle, impossible intervals — and replaces everything in one
  transaction.
- Dose-history CSV (every entry, with which ones count) and the plain-text
  patient summary, in `lib/export/`. Saved through Android's picker
  (`DocumentService`, the same few lines of Kotlin as Ebb's) instead of email.
- `lib/data/sample_data.dart` and `dart run tool/sample_history.dart out.json`
  for fictional data built around the current time.

### 3. Reminders — done, pending real-phone time

- `lib/domain/reminder_planner.dart` is pure and tested in five time zones.
  A reminder fires at a moment exactly when the engine would say, at that
  moment, that a dose is coming up, due or overdue — so reminders and screens
  can't disagree. It plans a week ahead, one notification per patient per
  minute.
- `lib/services/notification_service.dart` hands the plan to Android:
  `exactAllowWhileIdle`, or `alarmClock` with the alarm sound repeating until
  dealt with for alarm-mode medications. `USE_EXACT_ALARM`, so no prompt.
  Each sync also clears shown notifications for doses given since.
- "Mark given" and "Snooze 5 min" work from the notification without opening
  the app (`onReminderAction`, run in a background isolate), then replan.
- Replanning happens on every app start and after every change. The
  plugin re-registers alarms after a reboot or update by itself.
- Tapping a reminder opens that patient; the screens reread the data on
  return and every 20 seconds, so a dose marked given from a notification
  shows up.

Checked on the Android 16 emulator: exact alarms granted at install and set
with no window. It also caught a planner bug: a reminder due a few seconds
before a replan (say, the app coming to the foreground) but not yet fired —
alarms fire at the next whole minute — was dropped. Fixed, with a test.
Watching reminders fire and using Mark given end to end waits for the real
screens; see the end of this file for what's still to try on real phones.

Decisions made here, all new since the PWA polled once a minute while open:

- **Overdue reminders stop after six repeats** (three hours at the default
  30 minutes), and at the next dose's due time. The PWA repeated for as long
  as the page stayed open, which as real alarms would ring all night.
- **An interval or as-needed medication never given has no reminders** —
  nothing to count from. (The PWA's "due now" for these moved with the clock,
  so it re-fired every minute.)
- **A reminder never fires before its time**: times are rounded up to the
  minute.
- **Reminders are planned a week ahead.** If Nexpill isn't opened, and no
  reminder is acted on, for about six and a half days, a notice asks for it
  to be opened so reminders don't run out.
- **No full-screen alarm.** Alarm mode uses the alarm sound and an
  alarm-clock alarm, but not a lock-screen takeover, which would need the app
  to show over the lock screen and another permission Android 14 restricts.
- **Travel.** Alarms are set at absolute instants. Fixed-time reminders move
  to the new time zone on the next replan (any app open), not the moment the
  zone changes.

### 4. Screens — done

`lib/ui/`, built like Ebb's (`StatefulWidget` and one `CareStore`, a plain
`ChangeNotifier`, through which every change replans reminders):

- **Care** (home): one patient's medications, most urgent first, each card
  saying the one thing to know ("Overdue 25 min", "Due in 8 min") with a
  Give button. Switch patient from the title. Stopped medications fold away
  at the bottom.
- **Give a dose**: now, or earlier; dose, given by (remembered), notes. Giving
  before the dose is due asks first. Undo from the snackbar.
- **History**: by day, corrections beside what they replaced; correct or
  delete an entry; save as CSV.
- **Medication editor**: all four schedule types (taper steps with dates),
  reminders (heads-up, overdue repeat, alarm mode), supply, stop or delete.
- **People**, **Settings** (notification and exact-alarm status, test
  reminder, backup, restore, summary, delete all, sample data in debug) and
  **About**.
- Colours are the SuperDaveLab family tokens (GridDock's `web/app.css`),
  light and dark; fonts as in Ebb.

Checked on the emulator: a real overdue reminder arrived with its buttons,
and "Mark given" from the shade logged the dose and moved the card on.

### Still to try on real phones

- Reminders across a reboot, and after the app is swiped away.
- An OEM battery saver (Samsung, Xiaomi, OnePlus) with the app unused for a
  day.
- "Mark given" from the lock screen.
- Daylight-saving change with fixed-time and interval medications scheduled
  across it.

## Changed from the PWA engine

Found while porting. The golden test skips or adjusts exactly the affected
cases, naming the item below, so every other answer is still checked against
the PWA.

1. **Fixed-time doses now count.** The PWA ignored dose history for fixed
   times, so a dose given at 08:05 still read "overdue" until 12:00. Now each
   dose counts for the slot nearest to when it was given (halfway between two
   slots goes to the later one): with slots at 08:00, 12:00 and 20:00, a dose
   at 07:50 or 08:20 is the 08:00 dose. The medication is next due at the
   slot after that — unless a later slot has since come round ungiven, which
   is then due and overdue until the one after it arrives. Missed slots are
   never made up; only the latest dose matters, as for intervals.
2. **Taper steps begin at local midnight.** The PWA used UTC midnight, so a
   step "from 5 June" began at 8 pm on 4 June in New York. The golden taper
   cases still run where local time is UTC (as in CI), where both agree.
3. **Unset reminder settings — to do in step 2.** With no settings saved, the
   PWA's reminder rules treated a scheduled medication as having reminders on
   while the engine gave it no early-reminder time. Recommended: no "unset"
   state at all. `Medication.reminderSettings` becomes required, stored as
   non-null columns, and a new medication starts with reminders **on** for
   interval, fixed-time and taper schedules and **off** for as-needed, with
   no early heads-up (0 minutes) and alarm mode off — the defaults the PWA's
   reminder rules already used. The form shows them, so what's stored is
   what the caregiver saw.
4. **Tapers can be "missed"**, by the same rule as intervals: half the
   current step's interval past due.
