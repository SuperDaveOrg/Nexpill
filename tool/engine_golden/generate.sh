#!/usr/bin/env bash
set -euo pipefail

# Regenerate test/fixtures/engine_golden.json from a checkout of the PWA.
#
# Runs generate.mts in several time zones and writes the fixture only if every
# zone gives the same answers, so the Dart test can run in any zone.
#
# Usage:
#   tool/engine_golden/generate.sh <pwa-checkout>
#
# <pwa-checkout> is the last commit of the React PWA, with `npm install` run.

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo="$(cd "$here/../.." && pwd)"
pwa="$(cd "${1:?usage: generate.sh <pwa-checkout>}" && pwd)"
tsx="$pwa/node_modules/.bin/tsx"
[[ -x $tsx ]] || { echo "generate.sh: no tsx in $pwa (run npm install there)" >&2; exit 1; }

out="$repo/test/fixtures/engine_golden.json"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

zones=(UTC America/Chicago Asia/Kolkata Pacific/Auckland Europe/London)
for zone in "${zones[@]}"; do
  (cd "$pwa" && TZ="$zone" "$tsx" "$here/generate.mts" "$pwa/src") > "$tmp/${zone//\//_}.json"
done

first="$tmp/UTC.json"
for f in "$tmp"/*.json; do
  cmp -s "$first" "$f" || {
    echo "generate.sh: answers differ between UTC and $(basename "$f" .json):" >&2
    diff "$first" "$f" | head -20 >&2
    exit 1
  }
done

mkdir -p "$(dirname "$out")"
cp "$first" "$out"
echo "Wrote $out ($(grep -c '"kind"' "$out") cases, same in ${#zones[@]} time zones)"
