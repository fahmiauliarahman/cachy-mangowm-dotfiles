#!/bin/sh
# wallpaper.sh [next|set <path>]; use the active Quattro theme's background.

set -eu

STATE="${XDG_CACHE_HOME:-$HOME/.cache}/mango/wallpaper"
THEME_STATE="${XDG_STATE_HOME:-$HOME/.local/state}/mango/theme"
THEMES="${XDG_CONFIG_HOME:-$HOME/.config}/mango/themes/backgrounds"
USER_WALLPAPERS="${XDG_DATA_HOME:-$HOME/.local/share}/mango/wallpapers"
mkdir -p "$(dirname "$STATE")"

theme=nord
[ ! -s "$THEME_STATE" ] || theme=$(cat "$THEME_STATE")

pick() {
	cur=""
	[ ! -f "$STATE" ] || cur=$(cat "$STATE")
	found=0
	first=""
	for img in "$THEMES/$theme"/* "$USER_WALLPAPERS/$theme"/*; do
		[ -f "$img" ] || continue
		case "$img" in *.png|*.jpg|*.jpeg|*.webp|*.gif|*.bmp) ;; *) continue ;; esac
		[ -n "$first" ] || first=$img
		if [ "$found" = 1 ]; then
			printf '%s\n' "$img"
			return
		fi
		[ "$img" != "$cur" ] || found=1
	done
	printf '%s\n' "$first"
}

apply() {
	img=$1
	[ -f "$img" ] || { echo "Wallpaper not found: $img" >&2; exit 1; }
	printf '%s\n' "$img" > "$STATE"
	killall swaybg 2>/dev/null || true
	swaybg -i "$img" -m fill >/dev/null 2>&1 &
}

case "${1:-}" in
set) apply "${2:?usage: wallpaper.sh set PATH}" ;;
""|next) img=$(pick); [ -z "$img" ] || apply "$img" ;;
*) echo "usage: wallpaper.sh [next|set <path>]" >&2; exit 1 ;;
esac
