#!/bin/sh
# Click the bluetooth icon. List devices, pair, connect, or disconnect.

set -eu

notify() {
	command -v notify-send >/dev/null 2>&1 && notify-send -a bluetooth "$1" "$2" || true
}

bt() {
	bluetoothctl --timeout 8 "$@"
}

powered=$(bluetoothctl show 2>/dev/null | awk -F': ' '/Powered:/ { print $2; exit }')
if [ "$powered" != "yes" ]; then
	bluetoothctl power on >/dev/null
fi

bluetoothctl scan on >/dev/null 2>&1 &
scan=$!
sleep 2
kill "$scan" 2>/dev/null || true
wait "$scan" 2>/dev/null || true

# mac, name, paired, connected
devices=$(bluetoothctl devices 2>/dev/null | awk '/^Device / { mac=$2; $1=$2=""; sub(/^ +/,""); print mac "\t" $0 }')

rows=""
printf '%s\n' "$devices" | while IFS=$(printf '\t') read -r mac name; do
	[ -n "$mac" ] || continue
	info=$(bluetoothctl info "$mac" 2>/dev/null || true)
	paired=$(printf '%s\n' "$info" | awk -F': ' '/Paired:/ { print $2; exit }')
	conn=$(printf '%s\n' "$info" | awk -F': ' '/Connected:/ { print $2; exit }')
	if [ "$conn" = "yes" ]; then
		state=connected
	elif [ "$paired" = "yes" ]; then
		state=paired
	else
		state=new
	fi
	printf '%s\t%s\t%s\n' "$mac" "$name" "$state"
done > /tmp/mango-bt.list

menu=$(awk -F'\t' '{ printf "%-28s  %s\n", $2, $3 }' /tmp/mango-bt.list)
menu=$(printf '%s\n%s\n' "turn off" "$menu")

choice=$(printf '%s\n' "$menu" | fuzzel --dmenu --prompt "bluetooth  " --width 42 --lines 12) || exit 0
[ -n "$choice" ] || exit 0

if [ "$choice" = "turn off" ]; then
	bluetoothctl power off >/dev/null
	notify "Bluetooth" "off"
	exit 0
fi

name=$(printf '%s\n' "$choice" | sed 's/  .*//')
mac=$(awk -F'\t' -v n="$name" '$2==n { print $1; exit }' /tmp/mango-bt.list)
state=$(awk -F'\t' -v n="$name" '$2==n { print $3; exit }' /tmp/mango-bt.list)
[ -n "$mac" ] || exit 1

if [ "$state" = "connected" ]; then
	if bt disconnect "$mac" >/tmp/mango-bt.log 2>&1; then
		notify "Bluetooth" "disconnected $name"
	else
		notify "Bluetooth" "$(tail -1 /tmp/mango-bt.log)"
	fi
	exit 0
fi

if [ "$state" != "paired" ]; then
	if ! bt pair "$mac" >/tmp/mango-bt.log 2>&1; then
		notify "Bluetooth" "$(tail -1 /tmp/mango-bt.log)"
		exit 1
	fi
	bt trust "$mac" >/dev/null 2>&1 || true
fi

if bt connect "$mac" >/tmp/mango-bt.log 2>&1; then
	notify "Bluetooth" "connected $name"
else
	notify "Bluetooth" "$(tail -1 /tmp/mango-bt.log)"
fi
