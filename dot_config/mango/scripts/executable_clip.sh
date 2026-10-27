#!/bin/sh
# Super+Ctrl+V.

set -eu

command -v cliphist >/dev/null 2>&1 || exit 1
sel=$(cliphist list | fuzzel --dmenu --prompt "clip  " --width 70 --lines 14) || exit 0
[ -n "$sel" ] || exit 0
printf '%s\n' "$sel" | cliphist decode | wl-copy
