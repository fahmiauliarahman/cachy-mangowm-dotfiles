#!/bin/sh
# Super+L / Super+Alt+L. tile -> scroller -> dwindle, and back.
# Falls back to switch_layout if the focused monitor can't be read.

set -eu

MON=$(mmsg get cursorpos 2>/dev/null | sed -n 's/.*"monitor":"\([^"]*\)".*/\1/p')
[ -n "$MON" ] || MON=$(mmsg get all-monitors 2>/dev/null | sed -n 's/.*"name":"\([^"]*\)".*/\1/p' | head -1)

sym=$(mmsg get monitor "$MON" 2>/dev/null | sed -n 's/.*"layout_symbol":"\([^"]*\)".*/\1/p')

case "${1:-next}" in
prev)
	case "$sym" in
	T) next=dwindle ;;
	S) next=tile ;;
	DW) next=scroller ;;
	*) next=tile ;;
	esac
	;;
*)
	case "$sym" in
	T) next=scroller ;;
	S) next=dwindle ;;
	DW) next=tile ;;
	*) next=tile ;;
	esac
	;;
esac

mmsg dispatch "setlayout,$next"
