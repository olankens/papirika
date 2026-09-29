#!/usr/bin/env bash

# shellcheck disable=SC2155
# shellcheck shell=bash

create_preview() {

	# Handle paths
	local scripts="$(cd "$(dirname "$0")" && pwd)"
	local icondir="$(cd "$scripts/.." && pwd)/source"
	local preview="$(cd "$scripts/.." && pwd)/.assets/preview-01.avif"
	local tempdir="$(mktemp -d)"

	# Gather icons
	mapfile -t members < <(find "$icondir" -maxdepth 2 -name "*.icns" | shuf | head -n 18)
	for element in "${!members[@]}"; do
		local current="${members[$element]}"
		[[ -e "$current" ]] || continue
		local iconset="$(mktemp -d)/icon.iconset"
		iconutil -c iconset "$current" -o "$iconset"
		local pngfile="$iconset/icon_512x512@2x.png"
		if [ ! -f "$pngfile" ]; then pngfile="$iconset/icon_512x512.png"; fi
		local col=$([ $((((element / 6) + element) % 2)) -eq 0 ] && echo "#abacae" || echo "#333333")
		magick "$pngfile" \
			-strip \
			-resize 128x128! \
			-bordercolor "$col" \
			-border 32x14 \
			"$tempdir/$(printf "%03d" $((element + 1))).png"
	done

	# Create preview
	{ magick montage "$tempdir"/*.png -tile 6x3 -geometry +0+0 png:- | avifenc --stdin --input-format png "$preview"; } || true

	# Remove remnants
	rm -rf "$tempdir"

}

update_dependencies() {

	# Update imagemagick
	printf "y\n" | brew install imagemagick
	printf "y\n" | brew upgrade imagemagick

	# Update avifenc
	printf "y\n" | brew install libavif
	printf "y\n" | brew upgrade libavif

}

main() {

	# Enable strictness
	set -euo pipefail

	# Update dependencies
	update_dependencies

	# Create preview
	create_preview

}

if [[ -z "${BASH_SOURCE[0]:-}" || "${BASH_SOURCE[0]}" == "$0" ]]; then main "$@"; fi
