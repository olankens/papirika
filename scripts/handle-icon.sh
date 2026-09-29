#!/usr/bin/env bash

# shellcheck disable=SC2155
# shellcheck shell=bash

main() {

	# Enable strictness
	set -euo pipefail

	# Define paths
	local scripts="$(cd "$(dirname "$0")" && pwd)"
	local icondir="$scripts/../source"
	local storage="$scripts/../.assets"
	local subject="$storage/Generated.png"
	local tempdir="$(mktemp -d)"

	# Handle layout
	local maximum=1024
	local gridnum=4
	local gapsize=16
	local boxsize=180

	# Create assets
	mkdir -p "$storage"

	# Gather icons
	find "$icondir" \
		-mindepth 2 \
		-maxdepth 2 \
		-type f \
		-not -path '*/_raw/*' \
		-iname '*.png' |
		shuf -n "$((gridnum * gridnum))" |
		while IFS= read -r file; do
			cp "$file" "$tempdir/"
		done

	# Create mosaic
	magick montage "$tempdir"/*.png \
		-font "/System/Library/Fonts/Supplemental/Arial.ttf" \
		-tile "${gridnum}x${gridnum}" \
		-geometry "${boxsize}x${boxsize}+${gapsize}+${gapsize}" \
		-background none \
		-pointsize 0 \
		"$tempdir/mosaic.png"

	# Create output
	magick "$tempdir/mosaic.png" \
		-background '#646464' \
		-gravity center \
		-extent "${maximum}x${maximum}" \
		-strip \
		"$subject"

}

if [[ -z "${BASH_SOURCE[0]:-}" || "${BASH_SOURCE[0]}" == "$0" ]]; then main "$@"; fi
