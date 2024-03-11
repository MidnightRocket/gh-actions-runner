#!/bin/sh
set -eu

print() { printf "%b%b" "${1-""}" "${2-"\\n"}"; }
stderr() { print "$@" 1>&2; }

readonly MAX_MINUTES="${DOCKER_MAX_MINUTES:-"60"}"

while true; do
	stderr "Docker cleaner"
	# https://stackoverflow.com/a/61734184
	docker ps -a --format "{{.ID}} {{.CreatedAt}}" | while read id cdate ctime _; do if [ "$(date '+%s' -d "$cdate $ctime")" -lt "$(date '+%s' -d "$MAX_MINUTES minutes ago")" ]; then docker rm -fv "$id"; fi; done
	# https://stackoverflow.com/a/57517491
	# Older than 3 month
	docker image prune -fa --filter "until=$((3 * 730))h"
	docker volume prune -fa

	if [ "--continous" = "${1:-""}" ]; then
		sleep 1000
	else
		exit 0
	fi
done
