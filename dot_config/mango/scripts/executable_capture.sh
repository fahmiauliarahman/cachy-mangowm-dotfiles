#!/bin/sh
# Super+Ctrl+C.

set -eu

DIR=$(CDPATH= cd -- "$(dirname "$0")" && pwd)
choice=$(printf '%s\n' region fullscreen color clipboard \
	| fuzzel --dmenu --prompt "capture  " --width 24 --lines 4) || exit 0

case "$choice" in
region) "$DIR/screenshot.sh" region ;;
fullscreen) "$DIR/screenshot.sh" full ;;
color) "$DIR/screenshot.sh" color ;;
clipboard) "$DIR/clip.sh" ;;
esac
