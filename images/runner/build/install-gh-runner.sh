#!/bin/sh
set -eu


GH_RUNNER_VERSION="$(curl -ISs "https://github.com/actions/runner/releases/latest" | awk 'BEGIN{RS="\r?\n";ORS=""}/^location/{gsub(/.*\/v/, "", $2);print $2}')"



ARCHIVE_NAME="actions-runner-linux-x64-${GH_RUNNER_VERSION}.tar.gz"


curl -o "$ARCHIVE_NAME" -L "https://github.com/actions/runner/releases/download/v$GH_RUNNER_VERSION/$ARCHIVE_NAME"
tar -xzf "./$ARCHIVE_NAME"
rm "./$ARCHIVE_NAME"

exec "./bin/installdependencies.sh"
