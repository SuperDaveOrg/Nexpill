#!/usr/bin/env bash
set -euo pipefail

# Build nexpill.superdavelab.com and deploy it to Apache on the SuperDaveLab host.
#
# Assembles dist/site/ from site/ plus: the logo, the store-listing
# screenshots (fastlane/.../phoneScreenshots — one set of files for the README,
# F-Droid and the page), and the newest *release* APK from dist/release/
# (build it first with tool/build_release.sh --ref vX.Y.Z). The page's
# double-brace placeholders are filled from that release: version, date,
# size, SHA-256, minimum Android version.
#
# Before the first release, --build-only still works: the placeholders get
# marked preview values so the page can be looked at. Deploying needs a real
# release.
#
# Then rsyncs dist/site/ to the server. Like LedgerSprout's deploy script, this
# never deletes anything remotely — old APKs stay downloadable until you remove
# them by hand.
#
# nexpill.superdavelab.com used to serve the PWA. site/sw.js retires its
# service worker in visitors' browsers; --retire-pwa, once, moves the old
# app's files aside on the server (to a dated backup) before deploying, so
# none of them linger. Its API service and database are separate; see
# docs/RELEASING.md.
#
# Usage:
#   tool/deploy_site.sh [--build-only | --dry-run] [--retire-pwa]
#
# Options:
#   --build-only   Assemble dist/site/ and stop (open dist/site/index.html)
#   --dry-run      Assemble, then show what rsync would send; touch nothing
#   --retire-pwa   First deploy only: move the old PWA's files on the server
#                  to /var/www/nexpill-pwa-retired-DATE before deploying
#   -h, --help     Show this help
#
# Environment overrides:
#   SSH_TARGET     default root@davekoons.com
#   REMOTE_DIR     default /var/www/nexpill
#   SITE_DOMAIN    default nexpill.superdavelab.com (for the post-deploy check)

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SSH_TARGET="${SSH_TARGET:-root@davekoons.com}"
REMOTE_DIR="${REMOTE_DIR:-/var/www/nexpill}"
SITE_DOMAIN="${SITE_DOMAIN:-nexpill.superdavelab.com}"
MODE=deploy
RETIRE_PWA=0

# Prints the comment block at the top of this file, and nothing after it.
usage() { awk 'NR > 1 && /^#/ { sub(/^# ?/, ""); print; seen = 1; next } seen { exit }' "$0"; }
die() { echo "deploy_site: $*" >&2; exit 1; }
say() { echo "==> $*"; }

while [[ $# -gt 0 ]]; do
  case "$1" in
    --build-only) MODE=build; shift ;;
    --dry-run) MODE=dry; shift ;;
    --retire-pwa) RETIRE_PWA=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) usage; exit 1 ;;
  esac
done

cd "$REPO"

# --- The release to offer ----------------------------------------------------

apk=""
for info in dist/release/nexpill-*.BUILD-INFO.txt; do
  [[ -f $info ]] || continue
  grep -q '^kind *release$' "$info" || continue   # never a snapshot or debug build
  candidate="dist/release/$(sed -n 's/^name *//p' "$info")"
  [[ -f $candidate ]] && apk="$apk$candidate"$'\n'
done
apk="$(printf '%s' "$apk" | sort -V | tail -1)"

# Android's API level, as the version people know.
android_version() {
  case "$1" in
    21) echo 5.0 ;; 22) echo 5.1 ;; 23) echo 6.0 ;; 24) echo 7.0 ;; 25) echo 7.1 ;;
    26) echo 8.0 ;; 27) echo 8.1 ;; 28) echo 9 ;; 29) echo 10 ;; 30) echo 11 ;;
    31) echo 12 ;; 32) echo 12L ;; 33) echo 13 ;; 34) echo 14 ;; 35) echo 15 ;;
    *) echo "API $1" ;;
  esac
}

if [[ -n $apk ]]; then
  APK_FILE="$(basename "$apk")"
  VERSION="$(sed -E 's/^nexpill-(.+)\.apk$/\1/' <<< "$APK_FILE")"
  [[ -f $apk.sha256 ]] || die "missing $apk.sha256"
  APK_SHA256="$(cut -d' ' -f1 "$apk.sha256")"
  [[ "$(sha256sum "$apk" | cut -d' ' -f1)" == "$APK_SHA256" ]] || die "$APK_FILE doesn't match its .sha256"
  APK_SIZE="$(awk '{ printf "%.0f MB", $1 / 1000000 }' <<< "$(stat -c %s "$apk")")"
  # The tag's date, not the build's: the day the version was released.
  RELEASE_DATE="$(git log -1 --format=%cd --date=format:'%B %-d, %Y' "v$VERSION" 2>/dev/null)" ||
    die "no tag v$VERSION"
  SDK="${ANDROID_HOME:-${ANDROID_SDK_ROOT:-$HOME/Android/Sdk}}"
  AAPT="$(ls -d "$SDK"/build-tools/*/ 2>/dev/null | sort -V | tail -1)aapt"
  [[ -x $AAPT ]] || die "no aapt under $SDK/build-tools"
  MIN_SDK="$("$AAPT" dump badging "$apk" | sed -n "s/^sdkVersion:'\([0-9]*\)'/\1/p")"
  MIN_ANDROID="$(android_version "$MIN_SDK")"
elif [[ $MODE == build ]]; then
  # A look at the page before the first release. Clearly not real.
  echo "Note: no release APK yet, so the page gets preview values."
  VERSION="0.0.0-preview"
  APK_FILE="nexpill-preview.apk"
  APK_SHA256="(preview: no release yet)"
  APK_SIZE="— MB"
  RELEASE_DATE="(not yet released)"
  MIN_ANDROID="7.0"
else
  die "no release APK in dist/release/ — run tool/build_release.sh --ref vX.Y.Z"
fi
YEAR="$(date +%Y)"

# --- Assemble -----------------------------------------------------------------

OUT="dist/site"
say "Building $OUT for Nexpill $VERSION"
rm -rf "$OUT"
mkdir -p "$OUT/assets/screenshots" "$OUT/downloads"
cp -r site/. "$OUT/"
cp assets/brand/nexpill_logo_512.png "$OUT/assets/logo.png"
cp fastlane/metadata/android/en-US/images/phoneScreenshots/*.png "$OUT/assets/screenshots/"
[[ -n $apk ]] && cp "$apk" "$apk.sha256" "$OUT/downloads/"

sed -i \
  -e "s|{{VERSION}}|$VERSION|g" \
  -e "s|{{APK_FILE}}|$APK_FILE|g" \
  -e "s|{{APK_SIZE}}|$APK_SIZE|g" \
  -e "s|{{APK_SHA256}}|$APK_SHA256|g" \
  -e "s|{{RELEASE_DATE}}|$RELEASE_DATE|g" \
  -e "s|{{MIN_ANDROID}}|$MIN_ANDROID|g" \
  -e "s|{{YEAR}}|$YEAR|g" \
  "$OUT/index.html"
if grep -o '{{[A-Z_]*}}' "$OUT/index.html" | sort -u | grep .; then
  die "unfilled placeholders above in $OUT/index.html"
fi

echo "    $APK_FILE ($APK_SIZE), released $RELEASE_DATE"
echo "    sha256 $APK_SHA256"

case "$MODE" in
  build)
    say "Built. Preview: $REPO/$OUT/index.html"
    exit 0 ;;
  dry)
    say "Dry run: what would go to $SSH_TARGET:$REMOTE_DIR"
    rsync -avzn "$OUT/" "$SSH_TARGET:$REMOTE_DIR/"
    exit 0 ;;
esac

# --- Deploy -------------------------------------------------------------------

if (( RETIRE_PWA )); then
  retired="$REMOTE_DIR-pwa-retired-$(date +%Y%m%d)"
  say "Moving the old PWA aside: $REMOTE_DIR -> $retired"
  ssh "$SSH_TARGET" "set -e; [ -d '$REMOTE_DIR' ] && [ ! -e '$retired' ] && mv '$REMOTE_DIR' '$retired' || true"
fi

say "Deploying to $SSH_TARGET:$REMOTE_DIR (never deletes remote files)"
ssh "$SSH_TARGET" "mkdir -p '$REMOTE_DIR'"
rsync -avz "$OUT/" "$SSH_TARGET:$REMOTE_DIR/"

say "Checking https://$SITE_DOMAIN/"
if curl -fsS -o /dev/null "https://$SITE_DOMAIN/downloads/$APK_FILE" -r 0-0; then
  echo "    live: https://$SITE_DOMAIN/ serves $APK_FILE"
else
  echo "    not reachable yet — if the subdomain isn't set up, that's expected."
  echo "    Files are on the server in $REMOTE_DIR."
fi
