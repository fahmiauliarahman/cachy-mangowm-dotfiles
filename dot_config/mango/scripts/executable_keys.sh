#!/bin/sh
# Super+K. List every bind from keybinds.conf in fuzzel.

set -eu

CONF="${XDG_CONFIG_HOME:-$HOME/.config}/mango/cfg/keybinds.conf"
[ -f "$CONF" ] || exit 1

awk '
	/^[[:space:]]*#/ { next }
	/^[[:space:]]*bind/ {
		line = $0
		sub(/^[[:space:]]*bind[a-z]*=/, "", line)
		n = split(line, a, ",")
		if (n < 3) next
		mod = a[1]
		key = a[2]
		cmd = a[3]
		arg = ""
		for (i = 4; i <= n; i++) arg = arg (i == 4 ? "" : ",") a[i]
		gsub(/^[[:space:]]+|[[:space:]]+$/, "", mod)
		gsub(/^[[:space:]]+|[[:space:]]+$/, "", key)
		gsub(/^[[:space:]]+|[[:space:]]+$/, "", cmd)
		gsub(/^[[:space:]]+|[[:space:]]+$/, "", arg)
		desc = desc_of(cmd, arg)
		printf "%-28s  %s\n", mod " + " key, desc
	}
	function desc_of(cmd, arg,    s) {
		if (cmd == "spawn" || cmd == "spawn_shell") {
			s = arg
			sub(/^[[:space:]]*sh[[:space:]]+-c[[:space:]]*/, "", s)
			gsub(/^["'\'']|["'\'']$/, "", s)
			if (length(s) > 52) s = substr(s, 1, 49) "..."
			return s
		}
		if (arg == "") return cmd
		return cmd "  " arg
	}
' "$CONF" | fuzzel --dmenu --prompt "keys  " --width 78 --lines 18
