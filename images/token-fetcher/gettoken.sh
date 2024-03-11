#!/bin/sh

set -eu
readonly SCRIPT_DIR="$(realpath "$(dirname -- "$0")")"
print() { printf "%b%b" "${1-""}" "${2-"\\n"}"; }
stderr() { print "$@" 1>&2; }
reportError() { stderr "$2"; return "$1"; }

commandv() { command -v "$1" || reportError "$?" "Executable '$1' not found"; }


PAT_TOKEN_FILE="/var/run/secrets/pat.token"
PAT_TOKEN="$(cat "$PAT_TOKEN_FILE")"


URL="https://api.github.com/repos/${USERNAME}/${REPOSITORY}/actions/runners/registration-token"


TOKEN_DIR="/tmp/token-cache"
REG_TOKEN_FILE="$TOKEN_DIR/token.json"

stderr "Token fetcher"

if ! [ -d "$TOKEN_DIR" ]; then
	mkdir -m 700 "$TOKEN_DIR"
fi


fetchToken() {
	stderr "Fetching token from: $URL"
	sleep 5
	curl -sL \
		-X POST \
		-H "Accept: application/vnd.github+json" \
		-H "Authorization: Bearer $PAT_TOKEN" \
		-H "X-GitHub-Api-Version: 2022-11-28" \
		"$URL" \
		> "$REG_TOKEN_FILE"
	stderr "Done fetching token"
}


if ! [ -f "$REG_TOKEN_FILE" ]; then
	fetchToken
fi


# REG_TOKEN_EXPIRE_DATE="$(jq '.expires_at | sub("\\.[[:digit:]]+"; "") | sub(":(?=[[:digit:]]{2}$)";"")| strptime("%Y-%m-%dT%H:%M:%S%z") | mktime' "$REG_TOKEN_FILE")" # Current cannot get to convert from timezone to UTC

LAST_MODIFY_DATE="$(stat --format "%Y" "$REG_TOKEN_FILE")"

EXPIRE_TIME_SEC="3600" # 1 hour
REG_TOKEN_EXPIRE_DATE="$((LAST_MODIFY_DATE + EXPIRE_TIME_SEC))"

NOW="$(date -u "+%s")"
if [ "$NOW" -gt "$REG_TOKEN_EXPIRE_DATE" ]; then
	stderr "Token expired"
	fetchToken
fi

stderr "Token will expire at: $(date -u -d "@$REG_TOKEN_EXPIRE_DATE")"
stderr "Current time: $(date -u -d "@$NOW")"

jq -r '.token' "$REG_TOKEN_FILE"
