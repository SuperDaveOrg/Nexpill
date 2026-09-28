# Security and privacy reports

Nexpill's core promise is simple: **your medication records stay on your
device.** It has no account and no server, and release builds can't use the
internet. If you find something that breaks that promise, or any other
security problem, please tell us privately first.

## How to report

Use GitHub's private form: **[Report a vulnerability](https://github.com/SuperDaveOrg/Nexpill/security/advisories/new)**
(Security tab → *Report a vulnerability*). Only the maintainers can see it.

Please don't open a public issue for these until there's a fix.

Helpful to include:

- the Nexpill version and your Android version;
- what you did, what you expected, and what happened;
- anything that shows the problem — ideally with made-up data, never real
  medication records.

## What counts

Anything that could let medication data leave the device, or be read by
someone or something it shouldn't, for example:

- a release build that can reach the network, or that asks for a permission
  it doesn't need;
- data ending up in Android's cloud backup or device-to-device transfer;
- another app being able to read Nexpill's data;
- a crafted backup file that crashes Nexpill, corrupts data, or does more
  than import the records it describes;
- a published APK that isn't signed by SuperDaveLab or doesn't match its
  published SHA-256.

Also worth reporting: anything that makes a reminder fire late, not at all,
or for the wrong dose.

Not in scope: someone who already has your unlocked phone opening the app.
See [docs/privacy.md](docs/privacy.md).

## Supported versions

Only the latest release gets fixes.
