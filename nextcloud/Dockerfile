FROM nextcloud:35.0.2
# The official image ships imagick (pecl) itself; the only addition is ghostscript (PDF previews).
# One layer, and a failing install fails the build.
RUN apt-get update \
 && apt-get install -y --no-install-recommends ghostscript \
 && rm -rf /var/lib/apt/lists/*
