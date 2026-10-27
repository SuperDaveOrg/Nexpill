# Nexpill backup format

A Nexpill backup is a UTF-8 JSON file holding everything on the phone:
patients, their medications, and every dose logged. This document is the
contract; `lib/data/backup.dart` is one implementation of it. The format is
public on purpose, so no one is locked in to Nexpill.

A file is written only when the user asks, and goes wherever they choose
through Android's Save picker. Restoring **replaces** everything on the phone,
in one step: a file with a problem anywhere is refused whole.

## Versioning

`nexpillBackup` is the format version, currently **5**. Adding an optional
field doesn't change it. Changing what a field means, or adding a required
one, needs a new version, a section here, and a reader that still accepts the
old versions. Nexpill refuses a file whose version it doesn't know.

An optional field that older versions of Nexpill would silently drop, where
dropping it would change what the app does, also gets a new version, so an
older app refuses the file instead of half-restoring it.

### Version history

| Version | |
|---|---|
| 1 | The first format. |
| 2 | Adds the medication's optional `course`. Without the version change, an older Nexpill would drop a course and keep reminding after it ended. A version 1 file is read as version 2 with no courses. |
| 3 | Adds the dose's optional `skipped`. Without the version change, an older Nexpill would read a skip as a dose given, using up supply and counting towards a course. A version 2 file is read as version 3 with no skips. |
| 4 | Adds the patient's optional `self`, for the phone's owner, whose `name` may then be absent. Without the version change, an older Nexpill would refuse a file with a nameless patient for the wrong reason, or forget who the owner is. A version 3 file is read as version 4 with no owner. |
| 5 | Adds the `once` schedule type, a single dose at a set time. Without the version change, an older Nexpill would refuse the file as having an unknown schedule type, rather than saying it needs updating. A version 4 file is read as version 5 unchanged. |

## Example

```json
{
  "nexpillBackup": 4,
  "exportedAt": "2026-06-10T14:30:00.000Z",
  "patients": [
    {
      "id": "5b0d…",
      "name": "Sam",
      "notificationsEnabled": true,
      "medications": [
        {
          "id": "a41c…",
          "name": "Amoxicillin",
          "strength": "500 mg capsules",
          "purpose": "Chest infection",
          "active": true,
          "defaultDose": "1 capsule",
          "schedule": { "type": "interval", "everyMinutes": 480 },
          "reminders": {
            "enabled": true,
            "earlyMinutes": 10,
            "overdueRepeatMinutes": 30,
            "alarm": false
          },
          "inventory": { "enabled": true, "startingQuantity": 21, "perDose": 1, "unit": "capsules", "lowAt": 4 },
          "doses": [
            { "id": "e7f2…", "givenAt": "2026-06-10T06:02:00.000Z" },
            { "id": "c9a0…", "givenAt": "2026-06-10T06:00:00.000Z", "corrects": "e7f2…", "givenBy": "Jo" }
          ]
        }
      ]
    }
  ]
}
```

## Fields

Optional fields may be absent or `null`. Every `id` is a string, unique in
the whole file; Nexpill writes random UUIDs.

### Top level

| Field | Type | |
|---|---|---|
| `nexpillBackup` | integer | Format version. |
| `exportedAt` | instant | When the file was written. Informational. |
| `patients` | array | Patients, each with their medications. |

### Patient

| Field | Type | |
|---|---|---|
| `id` | string | |
| `name` | string | Not empty. Optional for the phone's owner (`self`), who needn't give a name. |
| `self` | boolean, optional | `true` for the phone's owner, tracking their own medications: the app says "you" rather than their name. At most one patient has it. Default `false`. |
| `notes` | string, optional | |
| `notificationsEnabled` | boolean, optional | `false` silences all this patient's reminders. Default `true`. |
| `medications` | array | |

### Medication

| Field | Type | |
|---|---|---|
| `id` | string | |
| `name` | string | Not empty. |
| `strength` | string, optional | Free text, e.g. "500 mg capsules". |
| `purpose` | string, optional | What it's for, in the user's words, e.g. "blood pressure". Added without a version change: an app that ignores it still does the same thing. |
| `instructions` | string, optional | |
| `active` | boolean, optional | `false` for a medication that's stopped but kept in history. Default `true`. |
| `defaultDose` | string | Not empty; what one dose usually is, e.g. "1 capsule". |
| `schedule` | object | See below. |
| `reminders` | object | See below. |
| `inventory` | object | See below. |
| `course` | object, optional | When the medication stops by itself. See below. Absent for one that carries on until stopped. |
| `doses` | array | Dose history, oldest first. |

### Schedule

`type` is one of:

| `type` | Fields | Meaning |
|---|---|---|
| `interval` | `everyMinutes` | Due that long after the last dose. |
| `fixedTimes` | `times`: array of `"HH:mm"` | Due at those times on the phone's clock every day. |
| `asNeeded` | `minimumMinutes` | Can be given once that long has passed since the last dose; never due or overdue. |
| `taper` | `steps`: array of `{from, until?, everyMinutes}` | An interval that changes by date. `from` and `until` are `YYYY-MM-DD` calendar days; a step applies from local midnight on `from` until local midnight on `until` (so not on `until` itself). The last step may be open-ended. |
| `once` | `at`: instant | A single dose, due at that moment. Finished once a dose of it is given or skipped, whenever that was logged for; nothing more is due after that. |

All minute values are positive integers.

### Reminders

| Field | Type | |
|---|---|---|
| `enabled` | boolean | |
| `earlyMinutes` | integer ≥ 0 | A heads-up this long before a dose is due; 0 for none. The app offers 0, 10 and 15. |
| `overdueRepeatMinutes` | positive integer | How often an overdue reminder repeats. |
| `alarm` | boolean, optional | Ring like an alarm when due. Default `false`. |

### Inventory

| Field | Type | |
|---|---|---|
| `enabled` | boolean | Whether supply is tracked. |
| `startingQuantity` | number, optional | How much there was to begin with, plus every refill. |
| `perDose` | number, optional | How much one dose uses. |
| `unit` | string, optional | e.g. "tablets", "ml". |
| `lowAt` | number, optional | Warn at or below this much. |

What's left is always worked out, never stored: `startingQuantity` minus
`perDose` for each dose that counts.

### Course

Exactly one of:

| Field | Type | |
|---|---|---|
| `lastDay` | `YYYY-MM-DD` | Given through that calendar day; the course finishes at local midnight at the end of it. |
| `doses` | positive integer | Finished once this many doses count: a dose another one `corrects` doesn't, so a correction doesn't use up a second dose. This is a total over the medication's whole history, not doses still to give. |

Once finished, nothing more is due and nothing is reminded; the medication
and its history stay. A taper's own steps end it, so Nexpill doesn't write
a course for a taper, nor for a `once` schedule, which its one dose ends; if
one is there, whichever ends first applies.

### Dose

| Field | Type | |
|---|---|---|
| `id` | string | |
| `givenAt` | instant | |
| `dose` | string, optional | What was given, if different from the default. |
| `givenBy` | string, optional | |
| `notes` | string, optional | |
| `corrects` | string, optional | The `id` of a dose of the same medication that this one replaces. The replaced dose stays in history but no longer counts. A correction can itself be corrected. |
| `skipped` | boolean, optional | `true` for a dose deliberately not given; `givenAt` is then when it was due. Default `false`. |

A skipped dose moves the medication on as if it had been given on time:
a `fixedTimes` one to its next time, an `interval` or `taper` one to an
interval after the skipped dose was due. A skip only counts for a dose the
last given one hasn't already covered: if the dose was given after all,
even before the time it was skipped for, the next is counted from the dose
given. A skip is never counted as given: it
uses no supply, doesn't count towards a course of `doses`, and isn't the
"last given" dose. `asNeeded` medications ignore it, and Nexpill never
writes one for them.

An **instant** is an ISO 8601 date and time with its offset, such as
`2026-06-10T06:00:00.000Z` or `2026-06-10T08:00:00+02:00`. A time without an
offset is refused, because it would mean different moments on different
phones. Nexpill writes UTC to the millisecond.
