#!/usr/bin/env bash

# shellcheck disable=SC2155
# shellcheck shell=bash

main() {

	# Enable strictness
	set -euo pipefail

	# Define paths
	local scripts="$(cd "$(dirname "$0")" && pwd)"
	local icondir="$scripts/../source"
	local subject="$scripts/../README.md"
	local maxcols=6

	# Gather icons
	local members=()
	while IFS= read -r line; do members+=("$line"); done < <(printf '%s\n' "$icondir"/*/*.png | grep -v '/_raw/')

	# Create table
	local payload="<table>\n"
	for i in "${!members[@]}"; do
		local deposit=$(basename "$(dirname "${members[$i]}")")
		((i % maxcols == 0)) && payload+="  <tbody><tr>\n"
		payload+="    <td align=\"center\" width=\"99999\"><p align=\"center\"><a href=\"source/${deposit}/${deposit}.icns\"><img src=\"source/${deposit}/${deposit}.png\" align=\"center\" width=\"96\"></a></p></td>\n"
		((i % maxcols == maxcols - 1)) && payload+="  </tr></tbody>\n"
	done
	(( ${#members[@]} % maxcols != 0 )) && payload+="  </tr></tbody>\n"
	payload+="</table>"

	# Inject table
	awk -v payload="$payload" '
	  /<!-- START_BLOCK -->/ { print; print payload; skip=1; next }
	  /<!-- CEASE_BLOCK -->/ { skip=0 }
	  !skip
	' "$subject" >"$subject.tmp" && mv "$subject.tmp" "$subject"

}

if [[ -z "${BASH_SOURCE[0]:-}" || "${BASH_SOURCE[0]}" == "$0" ]]; then main "$@"; fi
