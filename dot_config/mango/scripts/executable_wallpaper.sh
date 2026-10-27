#!/bin/sh
# Cycle dark CachyOS wallpapers.
# wallpaper.sh [next|set <path>]

set -eu

WALL_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/mango/wallpapers"
STATE="${XDG_CACHE_HOME:-$HOME/.cache}/mango/wallpaper"
POOL="/usr/share/wallpapers/cachyos-wallpapers"
mkdir -p "$WALL_DIR" "$(dirname "$STATE")"

if [ ! -e "$WALL_DIR/.seeded" ]; then
	for name in \
		Dimensions.png Lines.png Metal.png north.png \
		DarkStreaks.png Spectrum.png wave.png wave2.png \
		"Cachy depths 5K.png" cachygalaxy99.jpg
	do
		src="$POOL/$name"
		[ -f "$src" ] && ln -sfn "$src" "$WALL_DIR/$name"
	done
	: > "$WALL_DIR/.seeded"
fi

pick() {
	set -- "$WALL_DIR"/*
	[ -e "$1" ] || exit 0
	cur=""
	[ -f "$STATE" ] && cur=$(cat "$STATE")
	next=""
	found=0
	for f in "$@"; do
		case "$f" in *.seeded) continue ;; esac
		if [ "$found" = 1 ]; then
			next=$f
			break
		fi
		if [ "$f" = "$cur" ]; then
			found=1
		fi
	done
	if [ -z "$next" ]; then
		for f in "$@"; do
			case "$f" in *.seeded) continue ;; esac
			next=$f
			break
		done
	fi
	printf '%s\n' "$next"
}

apply() {
	img=$1
	[ -f "$img" ] || exit 1
	printf '%s\n' "$img" > "$STATE"
	killall swaybg 2>/dev/null || true
	swaybg -i "$img" -m fill >/dev/null 2>&1 &
}

case "${1:-}" in
set)
	apply "$2"
	;;
""|next)
	apply "$(pick)"
	;;
*)
	echo "usage: wallpaper.sh [next|set <path>]" >&2
	exit 1
	;;
esac
