# Nexpill backup format

A Nexpill backup is a UTF-8 JSON file holding everything on the phone:
patients, their medications, and every dose logged. This document is the
contract; `lib/data/backup.dart` is one implementation of it. The format is
public on purpose, so no one is locked in to Nexpill.

A file is written only when the user asks, and goes wherever they choose
through Android's Save picker. Restoring **replaces** everything on the phone,
in one step: a file with a problem anywhere is refused whole.

## Versioning

`nexpillBackup` is the format version, currently **1**. Adding an optional
field doesn't change it. Changing what a field means, or adding a required
one, needs a new version, a section here, and a reader that still accepts the
old versions. Nexpill refuses a file whose version it doesn't know.

## Example

```json
{
  "nexpillBackup": 1,
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
| `name` | string | Not empty. |
| `notes` | string, optional | |
| `notificationsEnabled` | boolean, optional | `false` silences all this patient's reminders. Default `true`. |
| `medications` | array | |

### Medication

| Field | Type | |
|---|---|---|
| `id` | string | |
| `name` | string | Not empty. |
| `strength` | string, optional | Free text, e.g. "500 mg capsules". |
| `instructions` | string, optional | |
| `active` | boolean, optional | `false` for a medication that's stopped but kept in history. Default `true`. |
| `defaultDose` | string | Not empty; what one dose usually is, e.g. "1 capsule". |
| `schedule` | object | See below. |
| `reminders` | object | See below. |
| `inventory` | object | See below. |
| `doses` | array | Dose history, oldest first. |

### Schedule

`type` is one of:

| `type` | Fields | Meaning |
|---|---|---|
| `interval` | `everyMinutes` | Due that long after the last dose. |
| `fixedTimes` | `times`: array of `"HH:mm"` | Due at those times on the phone's clock every day. |
| `asNeeded` | `minimumMinutes` | Can be given once that long has passed since the last dose; never due or overdue. |
| `taper` | `steps`: array of `{from, until?, everyMinutes}` | An interval that changes by date. `from` and `until` are `YYYY-MM-DD` calendar days; a step applies from local midnight on `from` until local midnight on `until` (so not on `until` itself). The last step may be open-ended. |

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
| `startingQuantity` | number, optional | How much there was to begin with. |
| `perDose` | number, optional | How much one dose uses. |
| `unit` | string, optional | e.g. "tablets", "ml". |
| `lowAt` | number, optional | Warn at or below this much. |

What's left is always worked out, never stored: `startingQuantity` minus
`perDose` for each dose that counts.

### Dose

| Field | Type | |
|---|---|---|
| `id` | string | |
| `givenAt` | instant | |
| `dose` | string, optional | What was given, if different from the default. |
| `givenBy` | string, optional | |
| `notes` | string, optional | |
| `corrects` | string, optional | The `id` of a dose of the same medication that this one replaces. The replaced dose stays in history but no longer counts. A correction can itself be corrected. |

An **instant** is an ISO 8601 date and time with its offset, such as
`2026-06-10T06:00:00.000Z` or `2026-06-10T08:00:00+02:00`. A time without an
offset is refused, because it would mean different moments on different
phones. Nexpill writes UTC to the millisecond.
