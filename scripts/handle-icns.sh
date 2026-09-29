#!/usr/bin/env bash

# shellcheck disable=SC2155
# shellcheck shell=bash

create_icns() {

	# Handle parameters
	local element="$1"

	# Create image
	local appname="$(basename "$element")"
	local program="/Applications/Icon Composer.app/Contents/Executables/ictool"
	"$program" "$element/$appname.icon" \
		--export-image \
		--output-file "$element/$appname.png" \
		--platform macOS \
		--rendition Dark \
		--width 1024 \
		--height 1024 \
		--scale 1

	# Create icon
	macicon icns "$element/$appname.png" --output "$element/$appname.icns" --force

	# Remove remnants
	rm -rf "$element/$appname.iconset"

	# Handle compression
	pngquant --force --output "$element/$appname.png" "$element/$appname.png"

}

update_dependencies() {

	# Update macicon
	printf "y\n" | brew install sundegan/tap/macicon
	printf "y\n" | brew upgrade sundegan/tap/macicon

	# Update pngquant
	printf "y\n" | brew install pngquant
	printf "y\n" | brew upgrade pngquant

}

main() {

	# Enable strictness
	set -euo pipefail

	# Update dependencies
	update_dependencies

	# Create icns
	local scripts="$(cd "$(dirname "$0")" && pwd)"
	local icondir="$(cd "$scripts/.." && pwd)/source"
	for element in "$icondir"/*; do
		[[ -d "$element/$(basename "$element").icon" ]] || continue
		create_icns "$element"
	done

}

if [[ -z "${BASH_SOURCE[0]:-}" || "${BASH_SOURCE[0]}" == "$0" ]]; then main "$@"; fi
