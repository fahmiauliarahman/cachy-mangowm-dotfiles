#!/usr/bin/env python3
"""Feed waybar tags + layout from mango IPC.

waybar 0.15 on this system has no mango/* module, so this polls mmsg.
One JSON line per tick: text is the tag row, class is the layout symbol.
"""

import json
import os
import subprocess
import sys
import time

MMSG = "/usr/bin/mmsg"
NAMES = {
    "T": "tile",
    "S": "scroll",
    "DW": "dwindle",
    "M": "mono",
    "G": "grid",
    "K": "deck",
    "F": "fair",
    "CT": "center",
    "RT": "right",
    "VS": "vscroll",
    "VT": "vtile",
    "VG": "vgrid",
    "VK": "vdeck",
    "VF": "vfair",
}


def monitor():
    raw = subprocess.check_output([MMSG, "get", "cursorpos"], text=True)
    return json.loads(raw)["monitor"]


def snapshot():
    mon = monitor()
    info = json.loads(subprocess.check_output([MMSG, "get", "monitor", mon], text=True))
    parts = []
    for tag in info["tags"]:
        n = tag["index"]
        if tag["is_urgent"]:
            color, bg = "#101520", "#ad401f"
        elif tag["is_active"]:
            color, bg = "#101520", "#6c7e97"
        elif tag["client_count"]:
            color, bg = "#d1dae8", ""
        else:
            continue
        if bg:
            parts.append(f'<span foreground="{color}" background="{bg}"> {n} </span>')
        else:
            parts.append(f'<span foreground="{color}"> {n} </span>')
    sym = info.get("layout_symbol", "?")
    text = "  ".join(parts)
    layout = NAMES.get(sym, sym)
    return {"text": text, "tooltip": f"{mon}  {layout}", "class": sym, "alt": layout}


def main():
    interval = float(os.environ.get("MANGO_BAR_INTERVAL", "0.4"))
    while True:
        try:
            print(json.dumps(snapshot(), separators=(",", ":")), flush=True)
        except Exception as exc:
            print(json.dumps({"text": "", "tooltip": str(exc), "class": "dead"}), flush=True)
        time.sleep(interval)


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        sys.exit(0)
