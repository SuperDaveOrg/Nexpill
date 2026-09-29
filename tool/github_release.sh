#!/usr/bin/env bash
set -euo pipefail

# Publish a built release to GitHub Releases: the universal APK the site
# offers, the per-ABI APKs F-Droid checks its builds against, a SHA-256 for
# each, and the version's CHANGELOG.md section as the notes.
#
# Run after tool/build_release.sh --ref vX.Y.Z and after pushing the tag. It
# builds nothing: it only uploads what dist/release/ already holds, and only
# a release build (never a snapshot or debug-signed one).
#
# Usage:
#   tool/github_release.sh [--dry-run] X.Y.Z
#
# Options:
#   --dry-run    Show the notes and files, publish nothing
#   -h, --help   Show this help

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DRY=0
VERSION=""

# Prints the comment block at the top of this file, and nothing after it.
usage() { awk 'NR > 1 && /^#/ { sub(/^# ?/, ""); print; seen = 1; next } seen { exit }' "$0"; }
die() { echo "github_release: $*" >&2; exit 1; }
say() { echo "==> $*"; }

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY=1; shift ;;
    -h|--help) usage; exit 0 ;;
    [0-9]*.[0-9]*.[0-9]*) VERSION="$1"; shift ;;
    *) usage; exit 1 ;;
  esac
done
[[ -n $VERSION ]] || { usage; exit 1; }

cd "$REPO"
command -v gh >/dev/null || die "gh not on PATH"

TAG="v$VERSION"
APK="dist/release/nexpill-$VERSION.apk"
INFO="dist/release/nexpill-$VERSION.BUILD-INFO.txt"
# Same names as tool/build_release.sh; F-Droid's recipe fetches the per-ABI
# ones from the release by these names.
APKS=("$APK")
for abi in armeabi-v7a arm64-v8a x86_64; do APKS+=("dist/release/nexpill-$VERSION-$abi.apk"); done
[[ -f $INFO ]] || die "no release build of $VERSION in dist/release/ — run tool/build_release.sh --ref $TAG"
grep -q '^kind *release$' "$INFO" || die "$APK isn't a release build"
FILES=()
for f in "${APKS[@]}"; do
  [[ -f $f && -f $f.sha256 ]] || die "$f or its .sha256 is missing — rerun tool/build_release.sh --ref $TAG"
  [[ "$(sha256sum "$f" | cut -d' ' -f1)" == "$(cut -d' ' -f1 "$f.sha256")" ]] ||
    die "$f doesn't match its .sha256"
  FILES+=("$f" "$f.sha256")
done

# The APKs must come from the tag GitHub has, not a local one that was moved.
commit="$(sed -n 's/^commit *//p' "$INFO")"
remote="$(git ls-remote origin "refs/tags/$TAG^{}" | cut -f1)"
[[ -n $remote ]] || die "$TAG isn't on GitHub yet — git push origin $TAG"
[[ $remote == "$commit" ]] || die "the APKs were built from $commit, but $TAG on GitHub is $remote"

# This version's CHANGELOG section, without its heading.
notes="$(awk -v v="$VERSION" '
  $0 ~ "^## \\[" v "\\]" { on = 1; next }
  on && /^## \[/ { exit }
  on { print }
' CHANGELOG.md | sed -e '/./,$!d')"
[[ -n $notes ]] || die "CHANGELOG.md has no section for $VERSION"

notes+="

---

**Verify the download**

\`nexpill-$VERSION.apk\` works on any phone and is the one offered at
https://nexpill.superdavelab.com. The others are smaller, each for one kind of
processor; nearly every current phone is \`arm64-v8a\`. All are built from tag
\`$TAG\` by \`tool/build_release.sh\`, which refuses any build asking for a
permission outside the allow-list — \`INTERNET\` above all.

\`\`\`
$(for f in "${APKS[@]}"; do printf 'SHA-256  %s  %s\n' "$(cut -d' ' -f1 "$f.sha256")" "${f##*/}"; done)
Signer   $(sed -n 's/^signer-sha256 *//p' "$INFO")
\`\`\`"

if (( DRY )); then
  say "Dry run: would create GitHub release $TAG with"
  printf '    %s\n' "${FILES[@]}"
  echo
  echo "$notes"
  exit 0
fi

say "Creating GitHub release $TAG"
gh release create "$TAG" "${FILES[@]}" \
  --verify-tag --title "Nexpill $VERSION" --notes "$notes"
