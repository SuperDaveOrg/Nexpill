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
# site/beta/ (nexpill.superdavelab.com/beta/) offers a preview of the next
# version instead: the newest *snapshot* build, an untagged commit signed with
# the release key and built after that release (tool/build_release.sh --ref
# <branch>). The main page asks for testers only while there's one; with
# none, the beta page says there's no preview right now.
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
#   --build-only   Assemble dist/site/ and stop (open dist/site/index.html,
#                  and dist/site/beta/index.html)
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

# The oldest Android an APK installs on, from its badging.
min_android() {
  local sdk aapt
  sdk="${ANDROID_HOME:-${ANDROID_SDK_ROOT:-$HOME/Android/Sdk}}"
  aapt="$(ls -d "$sdk"/build-tools/*/ 2>/dev/null | sort -V | tail -1)aapt"
  [[ -x $aapt ]] || die "no aapt under $sdk/build-tools"
  android_version "$("$aapt" dump badging "$1" | sed -n "s/^sdkVersion:'\([0-9]*\)'/\1/p")"
}

# Checks an APK against its .sha256 and prints the hash.
apk_sha256() {
  [[ -f $1.sha256 ]] || die "missing $1.sha256"
  local sha
  sha="$(cut -d' ' -f1 "$1.sha256")"
  [[ "$(sha256sum "$1" | cut -d' ' -f1)" == "$sha" ]] || die "$(basename "$1") doesn't match its .sha256"
  echo "$sha"
}

apk_size() { awk '{ printf "%.0f MB", $1 / 1000000 }' <<< "$(stat -c %s "$1")"; }

if [[ -n $apk ]]; then
  APK_FILE="$(basename "$apk")"
  VERSION="$(sed -E 's/^nexpill-(.+)\.apk$/\1/' <<< "$APK_FILE")"
  APK_SHA256="$(apk_sha256 "$apk")"
  APK_SIZE="$(apk_size "$apk")"
  # The tag's date, not the build's: the day the version was released.
  RELEASE_DATE="$(git log -1 --format=%cd --date=format:'%B %-d, %Y' "v$VERSION" 2>/dev/null)" ||
    die "no tag v$VERSION"
  MIN_ANDROID="$(min_android "$apk")"
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

# --- The beta to offer --------------------------------------------------------

# The newest snapshot built after the release, so a beta whose changes have
# since been released stops being offered. Never a debug-signed build.
built_of() { sed -n 's/^built *//p' "$1"; }
release_built=""
[[ -n $apk ]] && release_built="$(built_of "${apk%.apk}.BUILD-INFO.txt")"
beta="" beta_info="" beta_built=""
for info in dist/release/nexpill-*.BUILD-INFO.txt; do
  [[ -f $info ]] || continue
  grep -q '^kind *snapshot$' "$info" || continue
  grep -q '^signer .*Android Debug' "$info" && continue
  built="$(built_of "$info")"
  candidate="dist/release/$(sed -n 's/^name *//p' "$info")"
  [[ -f $candidate && $built > $beta_built && $built > $release_built ]] || continue
  beta="$candidate" beta_info="$info" beta_built="$built"
done

if [[ -n $beta ]]; then
  BETA_APK_FILE="$(basename "$beta")"
  BETA_VERSION="$(sed -E 's/^nexpill-(.+)\.apk$/\1/' <<< "$BETA_APK_FILE")"
  BETA_APK_SHA256="$(apk_sha256 "$beta")"
  BETA_APK_SIZE="$(apk_size "$beta")"
  BETA_BUILT="$(date -d "$beta_built" +'%B %-d, %Y')"
  BETA_COMMIT="$(sed -n 's/^commit *//p' "$beta_info")"
  BETA_MIN_ANDROID="$(min_android "$beta")"
  # The page links to the commit on GitHub.
  [[ -n "$(git branch -r --contains "$BETA_COMMIT" 2>/dev/null)" ]] ||
    echo "Note: beta commit ${BETA_COMMIT:0:9} isn't on any remote branch, so the beta page's"$'\n'"      source link won't work until it's pushed."
fi

# --- Assemble -----------------------------------------------------------------

OUT="dist/site"
say "Building $OUT for Nexpill $VERSION"
rm -rf "$OUT"
mkdir -p "$OUT/assets/screenshots" "$OUT/downloads"
cp -r site/. "$OUT/"
cp assets/brand/nexpill_logo_512.png "$OUT/assets/logo.png"
cp fastlane/metadata/android/en-US/images/phoneScreenshots/*.png "$OUT/assets/screenshots/"
[[ -n $apk ]] && cp "$apk" "$apk.sha256" "$OUT/downloads/"
[[ -n $beta ]] && cp "$beta" "$beta.sha256" "$OUT/downloads/"

sed -i \
  -e "s|{{VERSION}}|$VERSION|g" \
  -e "s|{{APK_FILE}}|$APK_FILE|g" \
  -e "s|{{APK_SIZE}}|$APK_SIZE|g" \
  -e "s|{{APK_SHA256}}|$APK_SHA256|g" \
  -e "s|{{RELEASE_DATE}}|$RELEASE_DATE|g" \
  -e "s|{{MIN_ANDROID}}|$MIN_ANDROID|g" \
  -e "s|{{YEAR}}|$YEAR|g" \
  "$OUT/index.html"

# The beta page keeps one of its two download blocks, and the main page's
# call for testers shows only while there's a beta to test.
if [[ -n $beta ]]; then
  sed -i -e '/<!-- \/\?BETA -->/d' "$OUT/index.html"
  sed -i \
    -e '/<!-- NO-BETA -->/,/<!-- \/NO-BETA -->/d' -e '/<!-- \/\?BETA -->/d' \
    -e "s|{{BETA_VERSION}}|$BETA_VERSION|g" \
    -e "s|{{BETA_LABEL}}|$BETA_VERSION|g" \
    -e "s|{{BETA_APK_FILE}}|$BETA_APK_FILE|g" \
    -e "s|{{BETA_APK_SIZE}}|$BETA_APK_SIZE|g" \
    -e "s|{{BETA_APK_SHA256}}|$BETA_APK_SHA256|g" \
    -e "s|{{BETA_BUILT}}|$BETA_BUILT|g" \
    -e "s|{{BETA_COMMIT}}|$BETA_COMMIT|g" \
    -e "s|{{BETA_COMMIT_SHORT}}|${BETA_COMMIT:0:9}|g" \
    -e "s|{{MIN_ANDROID}}|$BETA_MIN_ANDROID|g" \
    "$OUT/beta/index.html"
else
  sed -i -e '/<!-- BETA -->/,/<!-- \/BETA -->/d' "$OUT/index.html"
  sed -i \
    -e '/<!-- BETA -->/,/<!-- \/BETA -->/d' -e '/<!-- \/\?NO-BETA -->/d' \
    -e "s|{{BETA_LABEL}}|none|g" \
    "$OUT/beta/index.html"
fi
sed -i -e "s|{{VERSION}}|$VERSION|g" -e "s|{{YEAR}}|$YEAR|g" "$OUT/beta/index.html"

for page in "$OUT/index.html" "$OUT/beta/index.html"; do
  if grep -o '{{[A-Z_]*}}' "$page" | sort -u | grep .; then
    die "unfilled placeholders above in $page"
  fi
done

echo "    $APK_FILE ($APK_SIZE), released $RELEASE_DATE"
echo "    sha256 $APK_SHA256"
if [[ -n $beta ]]; then
  echo "    preview: $BETA_APK_FILE ($BETA_APK_SIZE), built $BETA_BUILT"
else
  echo "    preview: none newer than the release; /beta/ says so"
fi

case "$MODE" in
  build)
    say "Built. Preview: $REPO/$OUT/index.html and $REPO/$OUT/beta/index.html"
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
