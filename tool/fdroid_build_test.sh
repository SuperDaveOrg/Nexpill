#!/usr/bin/env bash
set -euo pipefail

# Run F-Droid's own build of Nexpill locally, before pushing a recipe change.
#
# Does what the "fdroid build" job in fdroiddata's CI does, in the same
# Docker image (registry.gitlab.com/fdroid/fdroidserver:buildserver-trixie):
# fetches the latest fdroidserver, then `fdroid fetchsrclibs` and
# `fdroid build --test --on-server` using docs/fdroid/com.superdavelab.nexpill.yml,
# pointed at a commit of this repo instead of GitHub. Only committed code is
# built: the commit is cloned from this repo, not the working tree.
#
# If dist/release/ has a signed APK built from that same commit (by
# tool/build_release.sh), the two are compared with apksigcopier, the check
# F-Droid runs before publishing the developer-signed APK.
#
# Takes 5-10 minutes. Needs Docker; the comparison needs apksigcopier
# (sudo apt install apksigcopier) and apksigner from the Android SDK.
#
# Usage:
#   tool/fdroid_build_test.sh [--ref REF] [--keep]
#
# Options:
#   --ref REF   Commit, tag or branch to build (default: HEAD)
#   --keep      Keep the work directory (Flutter checkout, logs) afterwards
#   -h, --help  Show this help

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APPID="com.superdavelab.nexpill"
IMAGE="registry.gitlab.com/fdroid/fdroidserver:buildserver-trixie"
REF=HEAD
KEEP=0

usage() { awk 'NR > 1 && /^#/ { sub(/^# ?/, ""); print; seen = 1; next } seen { exit }' "$0"; }
die() { echo "fdroid_build_test: $*" >&2; exit 1; }
say() { echo "==> $*"; }

while [[ $# -gt 0 ]]; do
  case "$1" in
    --ref) REF="${2:?--ref needs a value}"; shift 2 ;;
    --keep) KEEP=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) usage; exit 1 ;;
  esac
done

command -v docker >/dev/null || die "Docker is needed"
COMMIT="$(git -C "$REPO" rev-parse --verify "$REF^{commit}")" || die "no such ref: $REF"
PUBSPEC_VERSION="$(git -C "$REPO" show "$COMMIT:pubspec.yaml" | sed -n 's/^version: *//p')"
VERSION_NAME="${PUBSPEC_VERSION%+*}"
VERSION_CODE="${PUBSPEC_VERSION#*+}"

WORK="$(mktemp -d "${TMPDIR:-/tmp}/nexpill-fdroid-test.XXXXXX")"
cleanup() {
  if (( KEEP )); then echo "Work directory kept: $WORK"; else rm -rf "$WORK"; fi
}
trap cleanup EXIT

say "Building $VERSION_NAME ($VERSION_CODE) from ${COMMIT:0:12} the way F-Droid does"
mkdir -p "$WORK/fdroiddata/metadata" "$WORK/fdroiddata/srclibs" "$WORK/fdroiddata/config"
git clone -q "$REPO" "$WORK/src"
git -C "$WORK/src" checkout -q "$COMMIT"
curl -fsSL -o "$WORK/fdroiddata/srclibs/flutter.yml" \
  https://gitlab.com/fdroid/fdroiddata/-/raw/master/srclibs/flutter.yml
curl -fsSL -o "$WORK/fdroiddata/config/fetch.fsck.skipList" \
  https://gitlab.com/fdroid/fdroiddata/-/raw/master/config/fetch.fsck.skipList

# The recipe, pointed at the local clone and this commit. Binaries and the
# signing key come out: that check is done below, against dist/release/.
python3 - "$REPO/docs/fdroid/$APPID.yml" "$WORK/fdroiddata/metadata/$APPID.yml" \
  "$COMMIT" "$VERSION_NAME" "$VERSION_CODE" <<'EOF'
import re, sys
src, dest, commit, name, code = sys.argv[1:]
s = open(src).read()
s = re.sub(r"(?m)^Repo: .*$", "Repo: /src", s)
s = re.sub(r"(?m)^(Binaries|AllowedAPKSigningKeys): .*\n", "", s)
s = re.sub(r"(?m)^(  - versionName: ).*$", rf"\g<1>{name}", s, count=1)
s = re.sub(r"(?m)^(    versionCode: ).*$", rf"\g<1>{code}", s, count=1)
s = re.sub(r"(?m)^(    commit: ).*$", rf"\g<1>{commit}", s, count=1)
open(dest, "w").write(s)
EOF

cat > "$WORK/run.sh" <<'EOF'
#!/bin/bash
# Inside the container: the setup and commands of fdroiddata's CI build job.
set -ex
source /etc/profile.d/bsenv.sh
mkdir -p $fdroidserver
curl --silent https://gitlab.com/fdroid/fdroidserver/-/archive/master/fdroidserver-master.tar.gz \
  | tar -xz --directory=$fdroidserver --strip-components=1
apt-get update -qq
apt-get install -y -qq sudo openjdk-21-jdk-headless >/dev/null
update-alternatives --set java /usr/lib/jvm/java-21-openjdk-amd64/bin/java
curl --silent 'https://gitlab.com/fdroid/fdroid-bootstrap-buildserver/-/raw/master/roles/production_hardening/files/gitconfig' \
  > $home_vagrant/.gitconfig
printf '[safe]\n\tdirectory = *\n' >> $home_vagrant/.gitconfig
for d in /fdroiddata/logs /fdroiddata/tmp /fdroiddata/unsigned $home_vagrant/.android $home_vagrant/.gradle $home_vagrant/metadata; do
  mkdir -p $d
done
cp /fdroiddata/metadata/*.yml $home_vagrant/metadata/
for d in srclibs tmp unsigned logs; do ln -sfn /fdroiddata/$d $home_vagrant/$d; done
ln -sfn /fdroiddata $home_vagrant/fdroiddata
chown -R vagrant $home_vagrant /fdroiddata
export GRADLE_USER_HOME=$home_vagrant/.gradle
cd $home_vagrant
fdroid="sudo --preserve-env --user vagrant env PATH=$fdroidserver:$PATH PYTHONPATH=$fdroidserver:$fdroidserver/examples PYTHONUNBUFFERED=true TERM=dumb HOME=$home_vagrant fdroid"
$fdroid fetchsrclibs "$APP" --verbose
$fdroid build --verbose --test --refresh-scanner --on-server --no-tarball "$APP"
EOF
chmod +x "$WORK/run.sh"

LOG="$REPO/dist/fdroid-test/build-${COMMIT:0:9}.log"
mkdir -p "$REPO/dist/fdroid-test"
say "Running the build in $IMAGE (log: ${LOG#"$REPO"/})"
if ! docker run --rm -e APP="$APPID:$VERSION_CODE" \
    -v "$WORK/fdroiddata:/fdroiddata" -v "$WORK/src:/src:ro" -v "$WORK/run.sh:/run.sh:ro" \
    "$IMAGE" /run.sh > "$LOG" 2>&1; then
  grep -n -E 'ERROR|What went wrong|^e: ' "$LOG" | head -20 >&2 || true
  die "F-Droid's build failed; see ${LOG#"$REPO"/}"
fi

UNSIGNED="$REPO/dist/fdroid-test/${APPID}_${VERSION_CODE}-${COMMIT:0:9}-unsigned.apk"
cp "$WORK/fdroiddata/tmp/${APPID}_${VERSION_CODE}.apk" "$UNSIGNED"
say "F-Droid's build succeeded: ${UNSIGNED#"$REPO"/}"

# The signed APK tool/build_release.sh made from this same commit, if any.
signed=""
for info in "$REPO"/dist/release/nexpill-*.BUILD-INFO.txt; do
  [[ -f $info ]] || continue
  grep -q "^commit *$COMMIT" "$info" || continue
  candidate="$REPO/dist/release/$(sed -n 's/^name *//p' "$info")"
  [[ -f $candidate ]] && signed="$candidate"
done
if [[ -z $signed ]]; then
  echo "    No signed APK from this commit in dist/release/, so no reproducibility check."
  echo "    Build one with: tool/build_release.sh --ref ${COMMIT:0:12}"
  exit 0
fi

SDK="${ANDROID_HOME:-${ANDROID_SDK_ROOT:-$HOME/Android/Sdk}}"
PATH="$(ls -d "$SDK"/build-tools/*/ 2>/dev/null | sort -V | tail -1):$PATH"
if ! command -v apksigcopier >/dev/null; then
  echo "    Install apksigcopier to compare (sudo apt install apksigcopier), then run:"
  echo "    apksigcopier compare ${signed#"$REPO"/} --unsigned ${UNSIGNED#"$REPO"/}"
  exit 0
fi
say "Comparing with ${signed#"$REPO"/}"
if apksigcopier compare "$signed" --unsigned "$UNSIGNED"; then
  say "Reproducible: F-Droid can publish the signed APK."
else
  die "not reproducible: F-Droid's build differs from ${signed#"$REPO"/}"
fi
