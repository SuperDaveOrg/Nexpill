# Nexpill — roadmap

What Nexpill does, what it should do next, and what it deliberately won't.
Items marked 🟡 need input from people who actually do the caregiving.

The Flutter app is being ported from the PWA; progress and behaviour
differences are tracked in [port-from-pwa.md](port-from-pwa.md). "Parity"
below is what the PWA did and the Flutter app must do before a first release.

---

## Parity for 0.x

| Feature | State |
|---|---|
| Timing engine: interval, fixed times, as needed (PRN), taper | Ported and verified |
| Status: too early, due soon, due now, overdue, missed, available | Ported and verified |
| Corrections that supersede a mistaken dose, kept in history | Ported (engine) |
| Inventory: remaining, low supply, out | Ported (engine) |
| Patients, and meds per patient | Done |
| Dose history per patient | Done, with corrections |
| Backup and restore | Done ([backup-format.md](backup-format.md)) |
| Dose-history CSV, printable summary | Done |
| Reminders: early notice, due now, repeating overdue, grouped per patient | Done, as exact OS alarms (`USE_EXACT_ALARM`) |
| Alarm mode for interval and fixed-time meds | Done: alarm sound until dealt with, Mark given / Snooze |
| Per-patient and per-medication reminder switches | Done |

---

## Next

From the PWA roadmap, still wanted:

- **What each medication is for.** A plain-language line ("for pain",
  "for nausea", "protects the stomach") shown on the card, in reminders and
  in the summary, for the patient who asks every time what a pill is for.
- **Declined doses.** Log that a dose was offered and refused, so history
  shows it and the caregiver can see what was and wasn't taken. 🟡 Whether a
  refusal should restart the interval, or leave the dose due, needs input.
- **"Given by" on each dose.** Already in the model; needs a field on the
  give-dose action, and a place in history and exports.
- **Timeline / calendar view** for spotting missed windows.
- **Notes per dose and per medication** for handovers between caregivers.
- **Structured doctor-visit export** (PDF).
- **Photo of the prescription label.** Adds `CAMERA` and storage decisions.

## Open questions 🟡

- **Sharing between caregivers.** Several people often look after one
  patient, and without a server their phones don't sync. For the first
  release, one phone is the record and a backup file can be handed over.
  After that, try Ebb-style phone-to-phone transfer (a backup as QR codes,
  no network) and see whether it's enough before considering anything
  more. Needs real caregivers' input.

## Won't do

- Diagnosis, dosage recommendations or treatment advice.
- A drug-interaction engine.
- Pharmacy, insurance or provider integrations.
- Accounts, cloud sync, or any server — see [privacy.md](privacy.md).
- Analytics, crash reporting or ads.
