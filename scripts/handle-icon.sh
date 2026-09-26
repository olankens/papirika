#!/usr/bin/env bash

# shellcheck disable=SC2155
# shellcheck shell=bash

#!/usr/bin/env bash

main() {

	set -euo pipefail

	local scripts_dir="$(cd "$(dirname "$0")" && pwd)"
	local source_dir="$scripts_dir/../source"
	local assets_dir="$scripts_dir/../.assets"
	local output="$assets_dir/Generated.png"
	local tmp="$(mktemp -d)"

	local size=1024
	local grid=4
	local gap=16
	local icon_size=180
	local font='/System/Library/Fonts/Supplemental/Arial.ttf'

	trap "rm -rf '$tmp'" EXIT
	mkdir -p "$assets_dir"

	find "$source_dir" \
		-mindepth 2 \
		-maxdepth 2 \
		-type f \
		-not -path '*/_raw/*' \
		-iname '*.png' |
		shuf -n "$((grid * grid))" |
		while IFS= read -r file; do
			cp "$file" "$tmp/"
		done

	magick montage "$tmp"/*.png \
		-font "$font" \
		-tile "${grid}x${grid}" \
		-geometry "${icon_size}x${icon_size}+${gap}+${gap}" \
		-background none \
		-pointsize 0 \
		"$tmp/mosaic.png"

	magick "$tmp/mosaic.png" \
		-background '#646464' \
		-gravity center \
		-extent "${size}x${size}" \
		-strip \
		"$output"

}

if [[ -z "${BASH_SOURCE[0]:-}" || "${BASH_SOURCE[0]}" == "$0" ]]; then main "$@"; fi
