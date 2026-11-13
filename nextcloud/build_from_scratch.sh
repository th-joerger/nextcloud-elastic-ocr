#!/bin/bash
# Build thorjoerger/nextcloud:<version> from the official nextcloud/docker Dockerfile (apache variant),
# bumped to a Nextcloud release the official image does not ship yet. Meant for urgent (security)
# releases only: as soon as Docker Hub has nextcloud:<version>, go back to the official image. Same
# Dockerfile, layout and entrypoint, so only the image tag in the compose changes.
#
# Usage: ./build_from_scratch.sh <version> [--push]
#   <version>  Nextcloud release, e.g. 35.0.3 (upstream must have <major>/apache)
#   --push     push the tag to Docker Hub after the smoke test (without it: build + test only)
# Env: IMAGE  (default thorjoerger/nextcloud)
#      DOCKER (default "sudo docker", like build.sh, so root's Docker Hub login is used)
#
# The Dockerfile keeps upstream's GPG check of the release tarball. The script aborts if anything
# but the NEXTCLOUD_VERSION line and the two download URLs would change.

set -euo pipefail

usage() { echo "usage: $0 <version> [--push]   e.g. $0 35.0.3 --push" >&2; exit 2; }

VERSION="${1:-}"
PUSH=no
case "${2:-}" in
  "") ;;
  --push) PUSH=yes ;;
  *) usage ;;
esac
[[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || usage
MAJOR="${VERSION%%.*}"
IMAGE="${IMAGE:-thorjoerger/nextcloud}"
read -ra DOCKER <<< "${DOCKER:-sudo docker}"
UPSTREAM=https://github.com/nextcloud/docker
RELEASE_URL="https://github.com/nextcloud-releases/server/releases/download/v${VERSION}/nextcloud-${VERSION}.tar.bz2"

# fail early on a typo or a release that is not published yet
if ! curl -fsIL -o /dev/null "$RELEASE_URL"; then
  echo "release tarball not found: $RELEASE_URL" >&2
  exit 1
fi

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

echo "==> clone $UPSTREAM"
git clone --quiet --depth 1 "$UPSTREAM" "$WORK/docker"
SRC="$WORK/docker/$MAJOR/apache"
DF="$SRC/Dockerfile"
[ -f "$DF" ] || { echo "upstream has no $MAJOR/apache/Dockerfile" >&2; exit 1; }
REV="$(git -C "$WORK/docker" rev-parse HEAD)"
echo "    upstream $(git -C "$WORK/docker" --no-pager log -1 --format='%h %cs %s')"

OLD="$(sed -nE 's/^ENV NEXTCLOUD_VERSION[ =]+//p' "$DF")"
[[ "$OLD" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || { echo "cannot read NEXTCLOUD_VERSION from $DF (got '$OLD')" >&2; exit 1; }

if [ "$OLD" = "$VERSION" ]; then
  echo "==> upstream Dockerfile already has $VERSION: check Docker Hub for nextcloud:$VERSION first"
elif [ "$(printf '%s\n%s\n' "$OLD" "$VERSION" | sort -V | tail -n 1)" != "$VERSION" ]; then
  echo "requested $VERSION is older than upstream $OLD" >&2
  exit 1
else
  echo "==> bump $OLD -> $VERSION in $MAJOR/apache/Dockerfile"
  sed -i "s/${OLD//./\\.}/${VERSION}/g" "$DF"
  read -r added removed _ <<< "$(git -C "$WORK/docker" diff --numstat)"
  if [ "$added" != 3 ] || [ "$removed" != 3 ]; then
    git -C "$WORK/docker" --no-pager diff >&2
    echo "unexpected diff (+$added/-$removed, expected +3/-3), abort" >&2
    exit 1
  fi
  git -C "$WORK/docker" --no-pager diff -U0 | grep -E '^[-+][^-+]' | cut -c1-160
fi

echo "==> build $IMAGE:$VERSION"
"${DOCKER[@]}" build --pull \
  --label "org.opencontainers.image.source=$UPSTREAM" \
  --label "org.opencontainers.image.revision=$REV" \
  --label "org.opencontainers.image.description=nextcloud/docker $MAJOR/apache, NEXTCLOUD_VERSION $OLD -> $VERSION" \
  --tag "$IMAGE:$VERSION" "$SRC"

echo "==> smoke test"
got="$("${DOCKER[@]}" run --rm --entrypoint php "$IMAGE:$VERSION" -r 'require "/usr/src/nextcloud/version.php"; echo $OC_VersionString;')"
if [ "$got" != "$VERSION" ]; then
  echo "image contains Nextcloud '$got', expected $VERSION" >&2
  exit 1
fi
mods="$("${DOCKER[@]}" run --rm --entrypoint php "$IMAGE:$VERSION" -m | grep -c -x -E 'apcu|imagick|memcached|redis' || true)"
if [ "$mods" != 4 ]; then
  echo "expected PHP modules apcu imagick memcached redis, found $mods of 4" >&2
  exit 1
fi
echo "    Nextcloud $got, $("${DOCKER[@]}" run --rm --entrypoint php "$IMAGE:$VERSION" -r 'echo "PHP ", PHP_VERSION;'), apcu imagick memcached redis ok"

if [ "$PUSH" = yes ]; then
  echo "==> push $IMAGE:$VERSION"
  "${DOCKER[@]}" push "$IMAGE:$VERSION"
else
  echo "==> not pushed. To push: ${DOCKER[*]} push $IMAGE:$VERSION"
fi
