#!/usr/bin/env bash
set -euo pipefail

# Build release APKs from an exact git commit, and prove they're what they
# claim: one universal APK (the website's download) and one per ABI (what
# F-Droid ships; see "ABI splits" in docs/RELEASING.md).
#
# Builds in a git worktree at a fixed path, so uncommitted changes can't leak
# in and the result depends only on the commit. The path is fixed because
# Flutter writes it into the compiled app: F-Droid rebuilds at the same path
# and publishes each per-ABI APK only if its build matches ours byte for byte
# (see "Reproducible builds" in docs/RELEASING.md). Then refuses to hand back
# the APKs if any one
#   - asks for any permission beyond the allow-list below (INTERNET above all),
#   - is signed with the debug key (unless --allow-debug-signing),
#   - has a version that disagrees with the tag it was built from,
#   - is signed by a different key from the others.
# Output goes to dist/release/: the APKs, a .sha256 for each, and
# BUILD-INFO.txt.
#
# Nothing is uploaded anywhere. See docs/RELEASING.md.
#
# Usage:
#   tool/build_release.sh [options]
#
# Options:
#   --ref <git-ref>          Commit or tag to build (default: HEAD)
#   --skip-tests             Skip flutter analyze and flutter test
#   --allow-debug-signing    Accept a debug-signed APK (testing this script;
#                            never for anything you give to people)
#   --keep-worktree          Leave the temporary checkout for inspection
#   -h, --help               Show this help

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PACKAGE="com.superdavelab.nexpill"

# The whole of what a release may ask for. Keep in step with
# android/app/src/main/AndroidManifest.xml. Nothing here is ever INTERNET.
ALLOWED_PERMISSIONS=(
  android.permission.POST_NOTIFICATIONS      # reminders
  android.permission.RECEIVE_BOOT_COMPLETED  # re-arm reminders after reboot
  android.permission.USE_EXACT_ALARM         # reminders on the minute
  android.permission.SCHEDULE_EXACT_ALARM    # the same, on Android 12
  android.permission.VIBRATE                 # reminders
  "$PACKAGE.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION"  # AndroidX, app-private
)

# The per-ABI APKs: Flutter's --target-platform, the ABI, and the digit that
# ends its version code (android/app/build.gradle.kts, and VercodeOperation in
# F-Droid's recipe). The universal APK's digit is 0.
ABIS=(
  "android-arm   armeabi-v7a 1"
  "android-arm64 arm64-v8a   2"
  "android-x64   x86_64      3"
)

REF="HEAD"
RUN_TESTS=1
ALLOW_DEBUG=0
KEEP_WORKTREE=0

# Prints the comment block at the top of this file, and nothing after it.
usage() { awk 'NR > 1 && /^#/ { sub(/^# ?/, ""); print; seen = 1; next } seen { exit }' "$0"; }
die() { echo "build_release: $*" >&2; exit 1; }
step() { echo; echo "==> $*"; }

while [[ $# -gt 0 ]]; do
  case "$1" in
    --ref) REF="$2"; shift 2 ;;
    --skip-tests) RUN_TESTS=0; shift ;;
    --allow-debug-signing) ALLOW_DEBUG=1; shift ;;
    --keep-worktree) KEEP_WORKTREE=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) usage; exit 1 ;;
  esac
done

# --- Tools -------------------------------------------------------------------

command -v flutter >/dev/null || die "flutter not on PATH"
SDK="${ANDROID_HOME:-${ANDROID_SDK_ROOT:-$HOME/Android/Sdk}}"
BUILD_TOOLS="$(ls -d "$SDK"/build-tools/*/ 2>/dev/null | sort -V | tail -1)"
[[ -n $BUILD_TOOLS ]] || die "no Android build-tools under $SDK"
AAPT="${BUILD_TOOLS}aapt"
APKSIGNER="${BUILD_TOOLS}apksigner"
[[ -x $AAPT && -x $APKSIGNER ]] || die "aapt/apksigner missing in $BUILD_TOOLS"

# --- Signing -----------------------------------------------------------------

KEY_PROPERTIES="${NEXPILL_KEY_PROPERTIES:-$REPO/android/key.properties}"
if [[ -f $KEY_PROPERTIES ]]; then
  export NEXPILL_KEY_PROPERTIES="$KEY_PROPERTIES"
elif (( ! ALLOW_DEBUG )); then
  die "no signing key: create android/key.properties (docs/RELEASING.md), or
       pass --allow-debug-signing to test the script with the debug key"
fi

# --- Checkout ----------------------------------------------------------------

COMMIT="$(git -C "$REPO" rev-parse --verify "$REF^{commit}")" || die "unknown ref: $REF"
SHORT="${COMMIT:0:9}"
# Never $TMPDIR: the path must be the same on every machine. F-Droid's recipe
# builds here too, so changing it means changing the recipe in fdroiddata.
WORKTREE="/tmp/nexpill-build"
if [[ -e $WORKTREE ]]; then
  # A worktree of ours left by --keep-worktree or an interrupted build.
  git -C "$REPO" worktree remove --force "$WORKTREE" 2>/dev/null ||
    die "$WORKTREE is in the way (another build running?); remove it and retry"
fi
cleanup() {
  if (( KEEP_WORKTREE )); then
    echo "Worktree kept at $WORKTREE"
  else
    git -C "$REPO" worktree remove --force "$WORKTREE" >/dev/null 2>&1 || rm -rf "$WORKTREE"
  fi
}
trap cleanup EXIT

step "Checking out $REF ($SHORT) into a clean worktree"
git -C "$REPO" worktree add --detach --quiet "$WORKTREE" "$COMMIT"
cd "$WORKTREE"

line="$(grep -E '^version: ' pubspec.yaml)"
[[ $line =~ ^version:\ ([0-9]+\.[0-9]+\.[0-9]+)\+([0-9]+)$ ]] || die "bad pubspec version: $line"
VERSION="${BASH_REMATCH[1]}"
CODE="${BASH_REMATCH[2]}"
IFS=. read -r MA MI PA <<< "$VERSION"
(( CODE == MA * 10000 + MI * 100 + PA )) ||
  die "pubspec code $CODE doesn't match $VERSION (use tool/bump_version.sh)"

# Only a commit carrying the matching tag is a release; anything else is
# labelled with its commit so it can't be mistaken for one.
if git tag --points-at "$COMMIT" | grep -qx "v$VERSION"; then
  KIND="release"
  NAME="nexpill-$VERSION"
else
  KIND="snapshot"
  NAME="nexpill-$VERSION-$SHORT"
  echo "Note: $SHORT isn't tagged v$VERSION, so this is a snapshot build."
fi

# F-Droid shows this as the release's "what's new", and caps it at 500
# characters. It looks the file up by each APK's own version code, so every
# ABI needs an identical copy.
if [[ $KIND == release ]]; then
  dir="fastlane/metadata/android/en-US/changelogs"
  first="$dir/$((CODE * 10 + 1)).txt"
  [[ -f $first ]] || die "no $first: write a short \"what's new\" for $VERSION
       there and copy it for the other ABIs (docs/RELEASING.md, step 2)"
  (( $(tr -d '\n' < "$first" | wc -m) <= 500 )) || die "$first is over F-Droid's 500 characters"
  for abi in "${ABIS[@]}"; do
    read -r _ _ digit <<< "$abi"
    notes="$dir/$((CODE * 10 + digit)).txt"
    cmp -s "$first" "$notes" || die "$notes is missing or differs from $first"
  done
fi

# --- Build -------------------------------------------------------------------

# Packages are fetched into the build path, as F-Droid's recipe does (so its
# scanner can inspect them), and at exactly the versions in pubspec.lock.
export PUB_CACHE="$WORKTREE/.pub-cache"
step "flutter pub get"
flutter pub get --enforce-lockfile >/dev/null

if (( RUN_TESTS )); then
  step "flutter analyze"
  flutter analyze
  step "flutter test"
  flutter test
fi

STAGE="$WORKTREE/build/release-apks"
mkdir -p "$STAGE"

# Each ABI is built on its own, the way F-Droid's recipe builds it, so its
# rebuild can match ours byte for byte.
for abi in "${ABIS[@]}"; do
  read -r platform name _ <<< "$abi"
  step "flutter build apk --release --split-per-abi --target-platform $platform"
  flutter build apk --release --split-per-abi --target-platform "$platform"
  apk="build/app/outputs/flutter-apk/app-$name-release.apk"
  [[ -f $apk ]] || die "build produced no $name APK"
  cp "$apk" "$STAGE/$name.apk"
done

step "flutter build apk --release (universal)"
flutter build apk --release
APK="build/app/outputs/flutter-apk/app-release.apk"
[[ -f $APK ]] || die "build produced no universal APK"
cp "$APK" "$STAGE/universal.apk"

# --- Verify ------------------------------------------------------------------

# Checks one APK's version code, permissions and signature. Leaves its
# permissions in $perms and its signer in $dn and $cert_sha.
verify_apk() {
  local apk="$1" label="$2" code="$3"
  local badging certs p a ok
  local -a bad=()

  badging="$("$AAPT" dump badging "$apk")"
  grep -q "package: name='$PACKAGE' versionCode='$code' versionName='$VERSION'" <<< "$badging" ||
    die "$label APK version doesn't match pubspec ($VERSION, APK code $code)"

  mapfile -t perms < <("$AAPT" dump permissions "$apk" |
    sed -n "s/^uses-permission: name='\([^']*\)'.*/\1/p" | sort -u)
  for p in "${perms[@]}"; do
    ok=0
    for a in "${ALLOWED_PERMISSIONS[@]}"; do [[ $p == "$a" ]] && ok=1; done
    (( ok )) || bad+=("$p")
  done
  (( ${#bad[@]} == 0 )) || die "$label APK asks for permissions outside the allow-list:
$(printf '         %s\n' "${bad[@]}")
       A dependency probably merged them in. Remove them in AndroidManifest.xml
       with tools:node=\"remove\" — never widen the allow-list for INTERNET."

  certs="$("$APKSIGNER" verify --print-certs "$apk")" || die "$label APK signature doesn't verify"
  # apksigner's line prefix varies between versions ("Signer #1 …", "Signer
  # (minSdkVersion=…) …"), so match on the field name alone. If the signer
  # can't be read, stop: an unreadable signer must never pass as a real one.
  dn="$(grep -m1 'certificate DN: ' <<< "$certs" | sed 's/.*certificate DN: //')"
  cert_sha="$(grep -m1 'certificate SHA-256 digest: ' <<< "$certs" | sed 's/.*SHA-256 digest: //')"
  [[ -n $dn && -n $cert_sha ]] || die "couldn't read the signing certificate from apksigner:
$certs"

  printf '  %-12s %s (%s), %d permissions, all allowed\n' "$label" "$VERSION" "$code" "${#perms[@]}"
}

step "Verifying the APKs"

for abi in "${ABIS[@]}"; do
  read -r _ name digit <<< "$abi"
  verify_apk "$STAGE/$name.apk" "$name" $((CODE * 10 + digit))
  signer_sha="${signer_sha:-$cert_sha}"
  [[ $cert_sha == "$signer_sha" ]] || die "$name APK is signed by a different key from the others"
done
verify_apk "$STAGE/universal.apk" universal $((CODE * 10))
[[ $cert_sha == "$signer_sha" ]] || die "universal APK is signed by a different key from the others"
echo "  no INTERNET in any of them"

if [[ $dn == *"Android Debug"* ]]; then
  (( ALLOW_DEBUG )) || die "APKs are debug-signed"
  NAME="$NAME-debugsigned"
  echo "  signature    DEBUG KEY — not for distribution"
else
  echo "  signature    $dn"
fi

# --- Output ------------------------------------------------------------------

OUT="$REPO/dist/release"
mkdir -p "$OUT"
# The universal APK keeps the plain name; the website's deploy script finds it
# through BUILD-INFO.txt's "name" line.
FILES=("$NAME.apk")
cp "$STAGE/universal.apk" "$OUT/$NAME.apk"
for abi in "${ABIS[@]}"; do
  read -r _ name _ <<< "$abi"
  FILES+=("$NAME-$name.apk")
  cp "$STAGE/$name.apk" "$OUT/$NAME-$name.apk"
done
for f in "${FILES[@]}"; do
  ( cd "$OUT" && sha256sum "$f" > "$f.sha256" )
done

sha_of() { cut -d' ' -f1 "$OUT/$1.sha256"; }
{
  echo "name          $NAME.apk"
  echo "kind          $KIND"
  echo "version       $VERSION ($CODE)"
  echo "commit        $COMMIT"
  echo "ref           $REF"
  echo "built         $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo "flutter       $(flutter --version 2>/dev/null | head -1)"
  echo "signer        $dn"
  echo "signer-sha256 $cert_sha"
  echo "apk-sha256    $(sha_of "$NAME.apk")"
  echo "apks          $((CODE * 10)) $NAME.apk $(sha_of "$NAME.apk")"
  for abi in "${ABIS[@]}"; do
    read -r _ name digit <<< "$abi"
    echo "              $((CODE * 10 + digit)) $NAME-$name.apk $(sha_of "$NAME-$name.apk")"
  done
  echo "permissions   ${perms[*]}"
} > "$OUT/$NAME.BUILD-INFO.txt"

step "Done"
for f in "${FILES[@]}"; do echo "  $OUT/$f (and .sha256)"; done
echo "  $OUT/$NAME.BUILD-INFO.txt"
