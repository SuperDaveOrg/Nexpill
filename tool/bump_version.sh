#!/usr/bin/env bash
set -euo pipefail

# Set Nexpill's version, and turn CHANGELOG.md's "Unreleased" section into it.
#
# The version lives in exactly one place, pubspec.yaml, as NAME+CODE. The code
# is derived from the name — major*10000 + minor*100 + patch — so there is no
# second counter to forget. This script never commits or tags; it prints the
# commands for that. See docs/RELEASING.md.
#
# Usage:
#   tool/bump_version.sh patch        0.1.0 -> 0.1.1
#   tool/bump_version.sh minor        0.1.1 -> 0.2.0
#   tool/bump_version.sh major        0.2.0 -> 1.0.0
#   tool/bump_version.sh 0.1.0        set exactly (e.g. the first release)

cd "$(dirname "${BASH_SOURCE[0]}")/.."

die() { echo "bump_version: $*" >&2; exit 1; }
# Prints the comment block at the top of this file, and nothing after it.
usage() { awk 'NR > 1 && /^#/ { sub(/^# ?/, ""); print; seen = 1; next } seen { exit }' "$0"; exit 1; }

[[ $# -eq 1 ]] || usage

line=$(grep -E '^version: ' pubspec.yaml) || die "no version line in pubspec.yaml"
[[ $line =~ ^version:\ ([0-9]+)\.([0-9]+)\.([0-9]+)\+([0-9]+)$ ]] ||
  die "pubspec version isn't NAME+CODE: '$line'"
major=${BASH_REMATCH[1]} minor=${BASH_REMATCH[2]} patch=${BASH_REMATCH[3]}
old_code=${BASH_REMATCH[4]}
old="$major.$minor.$patch"

case "$1" in
  major) major=$((major + 1)); minor=0; patch=0 ;;
  minor) minor=$((minor + 1)); patch=0 ;;
  patch) patch=$((patch + 1)) ;;
  [0-9]*.[0-9]*.[0-9]*)
    [[ $1 =~ ^([0-9]+)\.([0-9]+)\.([0-9]+)$ ]] || die "not X.Y.Z: $1"
    major=${BASH_REMATCH[1]} minor=${BASH_REMATCH[2]} patch=${BASH_REMATCH[3]} ;;
  *) usage ;;
esac

# Two digits each for minor and patch keep the derived code unique.
(( minor < 100 && patch < 100 )) || die "minor and patch must stay below 100"

new="$major.$minor.$patch"
code=$((major * 10000 + minor * 100 + patch))
(( code >= old_code )) || die "versions only go up: $old+$old_code -> $new+$code"

sed -i -E "s/^version: .*/version: $new+$code/" pubspec.yaml

# CHANGELOG: "## [Unreleased]" keeps its place at the top; everything under it
# becomes the new version's section.
if grep -q "^## \[$new\]" CHANGELOG.md; then
  echo "CHANGELOG.md already has a section for $new; left alone."
else
  grep -q '^## \[Unreleased\]' CHANGELOG.md || die "CHANGELOG.md has no '## [Unreleased]' heading"
  sed -i "0,/^## \[Unreleased\]/s//## [Unreleased]\n\n## [$new] - $(date +%F)/" CHANGELOG.md
fi

echo "Version: $old+$old_code -> $new+$code"
cat <<EOF

Next (docs/RELEASING.md, "Cutting a release"):
  1. Check CHANGELOG.md reads well for $new, and write a short summary for
     F-Droid in fastlane/metadata/android/en-US/changelogs/$code.txt
     (500 characters at most; release builds refuse to run without it).
  2. git commit -am "Release v$new", push, open a PR, merge once CI passes.
  3. On main: git tag -a v$new -m "Release v$new" && git push origin v$new
  4. tool/build_release.sh --ref v$new, then publish (docs/RELEASING.md)
EOF
