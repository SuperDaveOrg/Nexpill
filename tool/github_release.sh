#!/usr/bin/env bash
set -euo pipefail

# Publish a built release to GitHub Releases: the same signed APK the site
# offers, its SHA-256, and the version's CHANGELOG.md section as the notes.
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
[[ -f $APK && -f $APK.sha256 && -f $INFO ]] ||
  die "no release build of $VERSION in dist/release/ — run tool/build_release.sh --ref $TAG"
grep -q '^kind *release$' "$INFO" || die "$APK isn't a release build"
[[ "$(sha256sum "$APK" | cut -d' ' -f1)" == "$(cut -d' ' -f1 "$APK.sha256")" ]] ||
  die "$APK doesn't match its .sha256"

# The APK must come from the tag GitHub has, not a local one that was moved.
commit="$(sed -n 's/^commit *//p' "$INFO")"
remote="$(git ls-remote origin "refs/tags/$TAG^{}" | cut -f1)"
[[ -n $remote ]] || die "$TAG isn't on GitHub yet — git push origin $TAG"
[[ $remote == "$commit" ]] || die "$APK was built from $commit, but $TAG on GitHub is $remote"

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

\`\`\`
SHA-256  $(cut -d' ' -f1 "$APK.sha256")  nexpill-$VERSION.apk
Signer   $(sed -n 's/^signer-sha256 *//p' "$INFO")
\`\`\`

The same APK is offered at https://nexpill.superdavelab.com. It is built from
tag \`$TAG\` by \`tool/build_release.sh\`, which refuses any build asking for
a permission outside the allow-list — \`INTERNET\` above all."

if (( DRY )); then
  say "Dry run: would create GitHub release $TAG with"
  echo "    $APK"
  echo "    $APK.sha256"
  echo
  echo "$notes"
  exit 0
fi

say "Creating GitHub release $TAG"
gh release create "$TAG" "$APK" "$APK.sha256" \
  --verify-tag --title "Nexpill $VERSION" --notes "$notes"
