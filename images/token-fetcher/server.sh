#!/bin/sh
set -eu
readonly SCRIPT_DIR="$(realpath "$(dirname -- "$0")")"

SOCKET_PATH="/token-endpoint/gettoken.sock"
TOKEN_SCRIPT="$SCRIPT_DIR/gettoken.sh"


until docker info > /dev/null; do sleep 0.5; done
"$SCRIPT_DIR/clean-docker.sh" --continous &


# Try to fetch from script
# If fails then it gets detected during container boot
"$TOKEN_SCRIPT" > /dev/null

if [ -e "$SOCKET_PATH" ]; then
	rm -f "$SOCKET_PATH"
fi

ncat --send-only -klU "$SOCKET_PATH" -c "printf 'HTTP/1.0 200 OK\n\n'; $TOKEN_SCRIPT"
