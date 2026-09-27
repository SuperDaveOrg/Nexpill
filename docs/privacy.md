# What "private" means in Nexpill

Read this before writing code, copy or UI for this project.

## What we mean

**The data belongs to the user. We never receive it, so we cannot sell it,
share it, hand it over, lose it in a breach, or look at it ourselves.**

That is the whole claim. It is a statement about *our* obligations and *our*
architecture.

Concretely:

- Everything logged — patients, medications, doses — is written to a database
  on the device and nowhere else.
- There is no account, no login, no server, no sync and no telemetry.
- The release build ships without the `INTERNET` permission, so Android itself
  prevents the app from sending anything anywhere. The promise is enforced by
  the operating system, not by our good intentions.
- The app is MIT-licensed and open source, so anyone can check the claim.

Nexpill once had an optional cloud account. It was removed rather than ported:
see [port-from-pwa.md](port-from-pwa.md).

## What we do NOT mean

**Nexpill is not secret software.** Taking medication, and helping someone
else take theirs, is ordinary. An app that whispers about it — disguising its
icon, blanking its notifications, locking itself by default — implies there is
something to be ashamed of, and gets in the way of a tired caregiver at 3 am.

So Nexpill does not:

- disguise its name, icon or notification text;
- default to requiring a PIN or biometric unlock;
- frame the user as being watched or in danger.

A reminder says plainly what it is for: "Amoxicillin for Sam is due now."

## Where the line falls

| Choice | Why it's in scope |
|---|---|
| No `INTERNET` permission | The data genuinely cannot leave. |
| `allowBackup="false"` and data extraction rules | Otherwise Android silently copies the database to the user's cloud backup, and "it stays on this phone" would be false. |
| No analytics, crash reporting or ad SDKs | Those are exactly the channels that leak health data to third parties. |
| Local-only reminders | Push would need a server that knows the medication schedule. The phone schedules its own alarms, which is also what makes them reliable. |
| Explicit, user-initiated export | The user can move their own data; we just never do it for them. |
| Unused plugin permissions stripped | So the permission list reads as exactly what the app does. |

Out of scope unless real users ask:

| Choice | Why it's out |
|---|---|
| App lock / PIN by default | Offer it as an option if asked; never a default. |
| Contentless notifications | A reminder that doesn't say which medication, for whom, is a worse reminder. |
| Encrypted-at-rest database by default | Adds a passphrase prompt for little gain on a locked phone. |

## Tone for user-facing copy

- Plain and calm. Caregivers use this under stress; say the one thing they
  need first ("Due now", "Next at 14:30").
- Precise about time. Never round a dose time in a way that could lead to
  giving it early.
- Never give medical advice. Nexpill tracks timing; it doesn't diagnose,
  recommend doses or check interactions.
- The privacy message is a reassurance, not a warning.

## The honest trade-off

**If the phone is lost, so is the history**, unless a backup file was saved.
There is no cloud copy, because a cloud copy is what we promised not to keep.
The mitigation is an easy, obvious, user-initiated backup, and saying so
plainly in the app.

The same choice means two caregivers' phones don't sync. How to share care
without a server is an open question on the [roadmap](roadmap.md).
