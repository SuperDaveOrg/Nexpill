#!/usr/bin/env bash
set -euo pipefail

# Build a release APK from an exact git commit, and prove it's what it claims.
#
# Builds in a git worktree at a fixed path, so uncommitted changes can't leak
# in and the result depends only on the commit. The path is fixed because
# Flutter writes it into the compiled app: F-Droid rebuilds at the same path
# and publishes this APK only if its build matches byte for byte (see
# "Reproducible builds" in docs/RELEASING.md). Then refuses to hand back an
# APK that
#   - asks for any permission beyond the allow-list below (INTERNET above all),
#   - is signed with the debug key (unless --allow-debug-signing),
#   - has a version that disagrees with the tag it was built from.
# Output goes to dist/release/: the APK, SHA256SUMS and BUILD-INFO.txt.
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
# characters.
if [[ $KIND == release ]]; then
  notes="fastlane/metadata/android/en-US/changelogs/$CODE.txt"
  [[ -f $notes ]] || die "no $notes: write a short \"what's new\" for $VERSION"
  (( $(tr -d '\n' < "$notes" | wc -m) <= 500 )) || die "$notes is over F-Droid's 500 characters"
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

step "flutter build apk --release"
flutter build apk --release
APK="build/app/outputs/flutter-apk/app-release.apk"
[[ -f $APK ]] || die "build produced no APK"

# --- Verify ------------------------------------------------------------------

step "Verifying the APK"

badging="$("$AAPT" dump badging "$APK")"
grep -q "package: name='$PACKAGE' versionCode='$CODE' versionName='$VERSION'" <<< "$badging" ||
  die "APK version doesn't match pubspec ($VERSION+$CODE)"
echo "  version     $VERSION ($CODE)"

mapfile -t perms < <("$AAPT" dump permissions "$APK" |
  sed -n "s/^uses-permission: name='\([^']*\)'.*/\1/p" | sort -u)
bad=()
for p in "${perms[@]}"; do
  ok=0
  for a in "${ALLOWED_PERMISSIONS[@]}"; do [[ $p == "$a" ]] && ok=1; done
  (( ok )) || bad+=("$p")
done
(( ${#bad[@]} == 0 )) || die "APK asks for permissions outside the allow-list:
$(printf '         %s\n' "${bad[@]}")
       A dependency probably merged them in. Remove them in AndroidManifest.xml
       with tools:node=\"remove\" — never widen the allow-list for INTERNET."
echo "  permissions ${#perms[@]}, all allowed, no INTERNET"

certs="$("$APKSIGNER" verify --print-certs "$APK")" || die "signature doesn't verify"
# apksigner's line prefix varies between versions ("Signer #1 …", "Signer
# (minSdkVersion=…) …"), so match on the field name alone. If the signer
# can't be read, stop: an unreadable signer must never pass as a real one.
dn="$(grep -m1 'certificate DN: ' <<< "$certs" | sed 's/.*certificate DN: //')"
cert_sha="$(grep -m1 'certificate SHA-256 digest: ' <<< "$certs" | sed 's/.*SHA-256 digest: //')"
[[ -n $dn && -n $cert_sha ]] || die "couldn't read the signing certificate from apksigner:
$certs"
if [[ $dn == *"Android Debug"* ]]; then
  (( ALLOW_DEBUG )) || die "APK is debug-signed"
  NAME="$NAME-debugsigned"
  echo "  signature   DEBUG KEY — not for distribution"
else
  echo "  signature   $dn"
fi

# --- Output ------------------------------------------------------------------

OUT="$REPO/dist/release"
mkdir -p "$OUT"
cp "$APK" "$OUT/$NAME.apk"
( cd "$OUT" && sha256sum "$NAME.apk" > "$NAME.apk.sha256" )
cat > "$OUT/$NAME.BUILD-INFO.txt" <<EOF
name          $NAME.apk
kind          $KIND
version       $VERSION ($CODE)
commit        $COMMIT
ref           $REF
built         $(date -u +%Y-%m-%dT%H:%M:%SZ)
flutter       $(flutter --version 2>/dev/null | head -1)
signer        $dn
signer-sha256 $cert_sha
apk-sha256    $(cut -d' ' -f1 "$OUT/$NAME.apk.sha256")
permissions   ${perms[*]}
EOF

step "Done"
echo "  $OUT/$NAME.apk"
echo "  $OUT/$NAME.apk.sha256"
echo "  $OUT/$NAME.BUILD-INFO.txt"
