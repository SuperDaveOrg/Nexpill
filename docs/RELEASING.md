# Releasing Nexpill

How versions are numbered, how a release is built, and how the signing key is
kept. The same process as Ebb's.

## Version numbers

Nexpill uses [semantic versioning](https://semver.org), `MAJOR.MINOR.PATCH`.
The Flutter app starts at **0.1.0**; the PWA's versions were never tagged or
released as an Android app. While the major number is 0 the app is early and
the rules are looser.

| Bump | When |
|---|---|
| **Patch** (0.1.0 → 0.1.1) | Fixes only. Nothing new to learn. |
| **Minor** (0.1.1 → 0.2.0) | New features, new screens, a database migration. |
| **Major** (0.x → 1.0, 1.x → 2.0) | 1.0 when it's been used for real and the open roadmap questions are settled. After that, only for a change existing users must know about — above all, anything that stops older backup files restoring. |

**The version lives in one place:** `pubspec.yaml`, as `NAME+CODE`. Android's
version code is derived from the name, never counted by hand:

```
code = major * 10000 + minor * 100 + patch        0.1.0 → 100, 1.2.3 → 10203
```

So minor and patch stay below 100, and the code always goes up with the
version, which Android and F-Droid require. `tool/bump_version.sh` enforces
both.

Three other version numbers exist and move **independently** of the app's:

| Number | Where | Changes when |
|---|---|---|
| Database schema | `NexpillDatabase.version` | The tables change. Add a migration; never edit a shipped one. |
| Backup format | Once it exists (step 2 of the port) | A field changes meaning. See `docs/backup-format.md`. |

## Tags

A release is an annotated tag `vX.Y.Z` on `main`, matching `pubspec.yaml`.
F-Droid watches these tags to find new versions, so a tag is a promise: never
move or reuse one.

## The signing key

Every APK is signed, and Android will only install an update signed with the
**same key** as the version already installed. So:

- **Lose the key and you can never update the app** for anyone who has it —
  they'd have to uninstall, losing their data unless they'd backed up.
- **Leak the key** and someone else can publish "updates".

Keep it outside the repository, with a backup somewhere safe (an encrypted
USB stick, a password manager's file storage). The build refuses to use the
debug key for a release.

F-Droid publishes APKs signed with this key too: it rebuilds each release
and ships the one from the GitHub release if the two match (see
"Reproducible builds"). So one key covers every copy of Nexpill — F-Droid,
GitHub releases, the website — and people can update from any of them.

### Creating it (once)

```bash
mkdir -p ~/.android-keys
keytool -genkeypair -v \
  -keystore ~/.android-keys/nexpill-release.jks \
  -alias nexpill -keyalg RSA -keysize 4096 -validity 36500 \
  -dname "CN=SuperDaveLab"
```

Then create `android/key.properties` (gitignored — never commit it):

```properties
storeFile=/home/dave/.android-keys/nexpill-release.jks
storePassword=…
keyAlias=nexpill
keyPassword=…
```

## Cutting a release

`main` should only change through pull requests that pass CI (give the GitHub
repository the same "Protect main" ruleset as Ebb), so the version bump goes
through one too. Tags aren't
covered by the ruleset; the tag is pushed on its own once the bump is merged.

```bash
# 1. Make sure main is what you want to ship, and CHANGELOG.md's
#    "Unreleased" section describes it.
git switch main && git pull

# 2. Set the version on a branch. Turns "Unreleased" into this version's
#    section.
git switch -c release-0.2.0
tool/bump_version.sh minor          # or patch / major / an exact X.Y.Z

# 2b. Write the store's release notes: a short, user-facing summary of the
#     CHANGELOG.md section, 500 characters at most, in
#     fastlane/metadata/android/en-US/changelogs/<versionCode>.txt (200.txt
#     for 0.2.0). build_release.sh refuses to build without it.

# 3. Commit, open a pull request, and merge it once CI passes. The notes are
#    a new file, so add them first: `commit -a` skips untracked files.
git add fastlane/metadata/android/en-US/changelogs/
git commit -am "Release v0.2.0"
git push -u origin release-0.2.0
gh pr create --fill && gh pr merge --rebase   # after CI is green

# 4. Tag the merged commit on main, and push only the tag.
git switch main && git pull
git tag -a v0.2.0 -m "Release v0.2.0"
git push origin v0.2.0

# 5. Build from the tag.
tool/build_release.sh --ref v0.2.0

# 6. Check F-Droid's build of the tag matches it (see "F-Droid").
tool/fdroid_build_test.sh --ref v0.2.0

# 7. Publish the same APK as a GitHub release; F-Droid takes it from there.
tool/github_release.sh --dry-run 0.2.0
tool/github_release.sh 0.2.0

# 8. Update the page at nexpill.superdavelab.com.
tool/deploy_site.sh
```

`tool/build_release.sh` builds in a clean temporary checkout of exactly that
tag, runs `flutter analyze` and `flutter test`, and then **refuses** the APK if:

- it asks for any permission outside the allow-list at the top of the script
  (notifications, boot, exact alarms, vibration) — `INTERNET` above all;
- it's signed with the debug key;
- its version doesn't match `pubspec.yaml`, or the code doesn't match the
  formula.

Output lands in `dist/release/` (gitignored): `nexpill-X.Y.Z.apk`, its `.sha256`,
and a `BUILD-INFO.txt` recording the commit, Flutter version and signing
certificate. Builds from an untagged commit are named
`nexpill-X.Y.Z-<commit>.apk` so they can't pass for a release.

`build_release.sh` uploads nothing; publishing is steps 7 and 8, separate
and deliberate.

`tool/github_release.sh` attaches that same APK and its `.sha256` to a GitHub
release for the tag, with the version's CHANGELOG.md section and the signing
certificate's fingerprint as the notes. It checks the APK was built from the
commit the tag points to on GitHub.

## The website

`tool/deploy_site.sh` builds nexpill.superdavelab.com from `site/`: the logo, the screenshots in `fastlane/.../phoneScreenshots`, and the
newest release APK from `dist/release/`, whose version, date, size, SHA-256
and minimum Android version fill the page's placeholders. It rsyncs to
`/var/www/nexpill` on the server and never deletes anything there.

```bash
tool/deploy_site.sh --build-only   # preview dist/site/index.html; works before any release
tool/deploy_site.sh --dry-run      # what would be sent
tool/deploy_site.sh                # deploy
```

The page promotes LedgerSprout, which pays for Nexpill staying free; keep
that section when editing.


## Reproducible builds

F-Droid rebuilds each release from source and publishes the developer-signed
APK only if its own build matches byte for byte. What makes that work:

- `build_release.sh` always builds at `/tmp/nexpill-build`, because Flutter
  writes the build path into the compiled app. F-Droid's recipe must use the
  same path.
- Packages come from `pubspec.lock` exactly (`--enforce-lockfile`), fetched
  into the build directory.
- `android/app/build.gradle.kts` leaves out AGP's VCS info and the
  dependency-metadata signing block, which F-Droid rejects.
- `android/reproducible.cmake` drops the linker build ID from any native
  plugin code.
- F-Droid deletes the `signingConfigs` block and the `signingConfig =` line
  from `build.gradle.kts` before building, one whole line at a time, so its
  APK comes out unsigned. Keep that line a single line (the choice of key is
  made in `releaseSigning` above it): split over several lines, the leftover
  pieces stop the file compiling, which is how Ebb's first F-Droid build
  failed.

## F-Droid

The recipe is drafted in [fdroid/com.superdavelab.nexpill.yml](fdroid/com.superdavelab.nexpill.yml),
the same as Ebb's apart from names. It follows fdroiddata's
`templates/build-flutter.yml` and has no comments, because fdroiddata wants
none, so the reasoning lives here:

- Flutter comes from F-Droid's `flutter` srclib, checked out at the version
  pinned in `.github/workflows/ci.yml`.
- The source is moved to `/tmp/nexpill-build` for `pub get` and the build,
  the same path `build_release.sh` uses, then moved back.
- `PUB_CACHE` is inside the source, so F-Droid's scanner checks every
  package; `scandelete` removes any binary it flags.
- One universal APK (no `--split-per-abi`), because it has to match the APK
  on the GitHub release byte for byte.

Before submitting or changing the recipe, test it locally:
`tool/fdroid_build_test.sh --ref <commit>` runs F-Droid's own build of that
commit in the Docker image fdroiddata's CI uses, and, if `dist/release/` has
a signed APK from the same commit, checks F-Droid's build matches it.

To submit: in your fork of https://gitlab.com/fdroid/fdroiddata, add the
recipe as `metadata/com.superdavelab.nexpill.yml` with the version fields
and `commit` (the full hash the tag points to) set to a real release, and
open a merge request. After that, F-Droid finds new versions from the tags
on its own. Store text, screenshots and per-version changelogs come from
`fastlane/metadata/android/` in this repo, keyed by version code.

## Keeping up to date

Flutter moves fast. For one developer the aim is to upgrade on purpose, not
constantly.

- **Packages** (pub.dev): Dependabot opens **one grouped pull request a month**
  with minor and patch updates (`.github/dependabot.yml`). CI runs on it —
  tests plus the permission check — so a green one is safe to merge. Major
  versions are ignored; take those deliberately.
- **The Flutter SDK is pinned** — **3.47.5**, in `.github/workflows/ci.yml`.
  Dependabot never touches it. Upgrade it deliberately, once or twice a year
  or when a plugin demands it, and do it locally and in CI together:
  `flutter upgrade`, fix what breaks (usually Gradle, the Android Gradle
  Plugin or Kotlin), update `flutter-version` in `ci.yml`, commit both.
- **`pubspec.lock` is committed**, so nothing changes under you between
  upgrades — and F-Droid builds exactly those versions.
- **Why there's no rush:** with no network access, most published
  vulnerabilities in dependencies can't be reached. The risk that matters is
  a dependency *adding a permission*, and CI catches that on every push.
- **Fewer dependencies, less churn.** Prefer a few lines of platform code over
  a plugin when the need is small, as with the backup file pickers.

## Not yet

- **Release builds in CI.** CI already checks every push, debug-signed. A
  tag-triggered signed build would need the signing key
  as a repository secret. Worth it once releases are regular; until then the
  key stays on one machine.
- **Per-processor APKs.** The script builds one universal APK, and so does
  F-Droid's recipe, since it must match it.
- **Generated changelogs.** The per-version files in
  `fastlane/metadata/android/en-US/changelogs/` are written by hand;
  generating them from `CHANGELOG.md` would keep the two in step.
