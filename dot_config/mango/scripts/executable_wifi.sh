#!/bin/sh
# Click the wifi icon. List networks, connect, or join a hidden one.

set -eu

notify() {
	command -v notify-send >/dev/null 2>&1 && notify-send -a wifi "$1" "$2" || true
}

ask() {
	printf '%s\n' "$1" | fuzzel --dmenu --prompt "$2" --width 46 --lines 12
}

pass() {
	printf '\n' | fuzzel --dmenu --prompt "$1" --password --width 36 --lines 0
}

list=$(nmcli -t -f IN-USE,SSID,SIGNAL,SECURITY device wifi list --rescan no \
	| awk -F: '
		{
			use = $1
			sec = $NF
			sig = $(NF - 1)
			ssid = $2
			for (i = 3; i <= NF - 2; i++) ssid = ssid ":" $i
			if (ssid == "" || seen[ssid]++) next
			mark = (use == "*") ? "connected" : sprintf("%3s%%", sig)
			lock = (sec == "" || sec == "--") ? "open" : "lock"
			printf "%s\t%s\t%s\n", ssid, mark, lock
		}
	')

menu=$(printf '%s\n%s\n' "hidden network" "disconnect" \
	| awk 'NR<=2 { print }' )
menu=$(printf '%s\n%s\n' "$menu" "$(printf '%s\n' "$list" | awk -F'\t' '{ printf "%-32s  %s  %s\n", $1, $2, $3 }')")

choice=$(printf '%s\n' "$menu" | ask "" "wifi  ") || exit 0
[ -n "$choice" ] || exit 0

case "$choice" in
"hidden network")
	ssid=$(printf '\n' | fuzzel --dmenu --prompt "ssid  " --width 36 --lines 0) || exit 0
	[ -n "$ssid" ] || exit 0
	psk=$(pass "password  ") || exit 0
	if nmcli device wifi connect "$ssid" password "$psk" hidden yes >/tmp/mango-wifi.log 2>&1; then
		notify "Wi-Fi" "connected to $ssid"
	else
		notify "Wi-Fi" "$(tail -1 /tmp/mango-wifi.log)"
	fi
	;;
disconnect)
	nmcli device disconnect wlan0 >/dev/null 2>&1 || true
	notify "Wi-Fi" "disconnected"
	;;
*)
	ssid=$(printf '%s\n' "$choice" | awk '{ print $1 }')
	# ssid may contain spaces; take everything before the status columns
	ssid=$(printf '%s\n' "$choice" | sed 's/  .*//')
	sec=$(printf '%s\n' "$list" | awk -F'\t' -v s="$ssid" '$1==s { print $3; exit }')
	if [ "$sec" = "open" ]; then
		if nmcli device wifi connect "$ssid" >/tmp/mango-wifi.log 2>&1; then
			notify "Wi-Fi" "connected to $ssid"
		else
			notify "Wi-Fi" "$(tail -1 /tmp/mango-wifi.log)"
		fi
	else
		psk=$(pass "password  ") || exit 0
		if nmcli device wifi connect "$ssid" password "$psk" >/tmp/mango-wifi.log 2>&1; then
			notify "Wi-Fi" "connected to $ssid"
		else
			notify "Wi-Fi" "$(tail -1 /tmp/mango-wifi.log)"
		fi
	fi
	;;
esac
