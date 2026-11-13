# nextcloud-elastic

Build files for a Nextcloud Docker image.

- `nextcloud/Dockerfile`, `nextcloud/build.sh`: the official `nextcloud` image plus ghostscript.
- `nextcloud/build_from_scratch.sh <version> [--push]`: builds the official [nextcloud/docker](https://github.com/nextcloud/docker) Dockerfile (apache variant) for a Nextcloud release the published image does not ship yet. Only the version lines change; the upstream GPG check of the release tarball stays.
