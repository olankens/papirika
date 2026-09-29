#!/usr/bin/env bash

# shellcheck disable=SC2155
# shellcheck shell=bash

main() {

	# Enable strictness
	set -euo pipefail

	# Invoke scripts
	local scripts="$(cd "$(dirname "$0")" && pwd)"
	bash "$scripts/handle-icns.sh"
	bash "$scripts/handle-readme.sh"

}

if [[ -z "${BASH_SOURCE[0]:-}" || "${BASH_SOURCE[0]}" == "$0" ]]; then main "$@"; fi
