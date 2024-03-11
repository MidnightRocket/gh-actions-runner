#!/usr/bin/dumb-init /bin/sh
set -eu
readonly SCRIPT_DIR="$(realpath "$(dirname -- "$0")")"
print() { printf "%b%b" "${1-""}" "${2-"\\n"}"; }
stderr() { print "$@" 1>&2; }
reportError() { stderr "$2"; return "$1"; }

commandv() { command -v "$1" || reportError "$?" "Executable '$1' not found"; }


sleep "$(shuf -i 3-6 -n 1 -z)"
fetchToken() {
	until TOKEN="$(curl -s --unix-socket "/token-endpoint/gettoken.sock" "http://tokenfetcher")"; do stderr "Failed to fetch token. Sleeping" ; sleep "$(shuf -i 3-9 -n 1 -z)"; done
}
fetchToken


stderr "TOKEN length: " ""
stderr "$(echo "$TOKEN" | wc -c)"


readonly GITHUB_BASE_URL="https://github.com"


readonly CONFIG_URL="$GITHUB_BASE_URL/$USERNAME/$REPOSITORY"

stderr "$CONFIG_URL"


readonly USER="runner"


readonly RUNNER_DIR="/gh-runner"

readonly CONFIG_SCRIPT="$RUNNER_DIR/config.sh"

readonly WORKDIR="/_work/$HOSTNAME"

readonly NAME_PREFIX="${NAME_PREFIX:-"docker"}"
readonly NAME="${NAME:-"$NAME_PREFIX-$HOSTNAME"}"

if ! [ -d "$WORKDIR" ]; then
	mkdir "$WORKDIR"
	chown "$USER:$USER" "$WORKDIR"
fi


removeRunner() {
	stderr "REMOVING runner"
	rm -rf "$WORKDIR"
	fetchToken
	stderr "Done fetching new token"
	gosu "$USER" "$CONFIG_SCRIPT" remove --token "$TOKEN" || stderr "Failed to remove runner"
	stderr "Done removing runner"
}

trap 'removeRunner; trap - EXIT' EXIT INT HUP TERM QUIT


gosu "$USER" "$CONFIG_SCRIPT" --url "$CONFIG_URL" --token "$TOKEN" --name "$NAME" --ephemeral --work "$WORKDIR" --unattended  --labels "${LABELS:-""}" --runnergroup "${GROUP:-"Default"}"

gosu "$USER" "$RUNNER_DIR/run.sh"
