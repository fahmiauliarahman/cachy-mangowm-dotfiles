#!/usr/bin/env python3
"""Display MangoWM keybindings as actions rather than raw shell commands."""

import os
from pathlib import Path
import subprocess
import sys

CONFIG = Path(os.environ.get("XDG_CONFIG_HOME", Path.home() / ".config")) / "mango/cfg/keybinds.conf"

ACTIONS = {
    "kitty": "Open Terminal",
    "kitty fish -c herdr": "Open Herdr",
    "helium-browser": "Open Browser",
    "helium-browser --incognito": "Open Private Browser",
    "dolphin": "Open Files",
    "kitty fish -c nvim": "Open Editor",
    "kitty fish -c btop": "Open Activity Monitor",
    "qalc": "Open Calculator",
    "fuzzel": "Open Applications",
    "~/.config/mango/scripts/power.sh": "Open Power Menu",
    "~/.config/mango/scripts/power.sh lock": "Lock Screen",
    "~/.config/mango/scripts/capture.sh": "Open Capture Menu",
    "~/.config/mango/scripts/radios.py wifi": "Open Wi-Fi Panel",
    "~/.config/mango/scripts/radios.py bluetooth": "Open Bluetooth Panel",
    "~/.config/mango/scripts/theme.py": "Choose Theme",
    "~/.config/mango/scripts/wallpaper.sh next": "Next Wallpaper",
    "~/.config/mango/scripts/clip.py": "Open Clipboard History",
    "~/.config/mango/scripts/keys.py": "Show Shortcuts",
    "~/.config/mango/scripts/layout.sh next": "Next Layout",
    "~/.config/mango/scripts/layout.sh prev": "Previous Layout",
    "~/.config/mango/scripts/screenshot.sh region": "Capture Region",
    "~/.config/mango/scripts/screenshot.sh color": "Pick Screen Color",
    "pavucontrol": "Open Audio Controls",
    "makoctl dismiss": "Dismiss Notification",
    "makoctl dismiss -a": "Dismiss All Notifications",
    "makoctl restore": "Restore Notification",
    "makoctl mode -t do-not-disturb": "Toggle Do Not Disturb",
    "playerctl play-pause": "Play or Pause Media",
    "playerctl next": "Next Track",
    "playerctl previous": "Previous Track",
    "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle": "Toggle Sound",
    "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle": "Toggle Microphone",
    "brightnessctl set 100%": "Maximum Brightness",
    "brightnessctl set 1%": "Minimum Brightness",
    "pkill -x waybar || waybar": "Toggle Top Bar",
}
DISPATCH = {
    "killclient": "Close Window", "togglefloating": "Toggle Floating Window",
    "togglefullscreen": "Toggle Fullscreen", "togglemaximizescreen": "Toggle Maximized Window",
    "togglefakefullscreen": "Toggle Fake Fullscreen", "toggleoverlay": "Toggle Overlay",
    "toggleglobal": "Toggle Sticky Window", "toggle_scratchpad": "Toggle Scratchpad",
    "minimized": "Minimize Window", "restore_minimized": "Restore Minimized Window",
    "dwindle_toggle_split_direction": "Toggle Split Direction",
    "toggle_render_border": "Toggle Window Border", "togglegaps": "Toggle Window Gaps",
    "switch_layout": "Switch Layout", "switch_proportion_preset": "Switch Window Width",
    "reload_config": "Reload MangoWM", "view": "View Workspace",
    "tag": "Move Window to Workspace", "tagsilent": "Move Window Without Following",
    "viewtoleft": "Previous Workspace", "viewtoright": "Next Workspace",
    "viewtoleft_have_client": "Previous Occupied Workspace",
    "viewtoright_have_client": "Next Occupied Workspace",
    "focusdir": "Focus Window", "exchange_client": "Swap Window",
    "focusmon": "Focus Monitor", "tagmon": "Move Window to Monitor",
    "focusstack": "Cycle Windows", "setmfact": "Resize Master Area",
    "resizewin": "Resize Window", "movewin": "Move Window",
    "set_proportion": "Set Window Width", "incgaps": "Adjust Gaps",
}
DIRECTIONS = {"left": "Left", "right": "Right", "up": "Up", "down": "Down", "next": "Next", "prev": "Previous"}


def label(action, argument):
    argument = argument.strip().strip('"')
    if action in ("spawn", "spawn_shell"):
        if argument in ACTIONS:
            return ACTIONS[argument]
        if argument.startswith("wpctl set-volume"):
            return "Raise Volume" if argument.endswith("+") else "Lower Volume"
        if argument.startswith("brightnessctl set"):
            return "Raise Brightness" if argument.endswith("+") else "Lower Brightness"
        return argument
    title = DISPATCH.get(action, action.replace("_", " ").title())
    detail = argument.split(",", 1)[0].strip()
    if action in ("view", "tag", "tagsilent") and detail.isdigit():
        return f"{title} {detail}"
    if action in ("focusdir", "exchange_client", "focusmon", "tagmon"):
        return f"{title} {DIRECTIONS.get(detail, detail.title())}"
    return title


def entries(config):
    for raw in config.splitlines():
        line = raw.strip()
        if not line.startswith(("bind =", "bindl =")):
            continue
        parts = [part.strip() for part in line.split(",", 3)]
        if len(parts) < 4:
            continue
        modifiers = parts[0].split("=", 1)[1].strip().replace("+", " + ")
        chord = (modifiers + " + " if modifiers != "NONE" else "") + parts[1]
        yield f"{chord:<33} {label(parts[2], parts[3])}", parts[2], parts[3]


def execute(action, argument):
    if action in ("spawn", "spawn_shell"):
        subprocess.Popen(argument, shell=True, start_new_session=True)
    else:
        subprocess.run(["mmsg", "dispatch", ",".join((action, argument)).rstrip(",")], check=True)


def main():
    if not CONFIG.is_file():
        print(f"Missing bindings: {CONFIG}", file=sys.stderr)
        return 1
    commands = {text: (action, argument) for text, action, argument in entries(CONFIG.read_text())}
    if len(sys.argv) == 2 and sys.argv[1] == "--print":
        print("\n".join(commands))
        return 0
    if len(sys.argv) != 1:
        print("usage: keys.py [--print]", file=sys.stderr)
        return 2
    selection = subprocess.run(
        ["fuzzel", "--dmenu", "--prompt", "shortcuts  ", "--width", "76", "--lines", "18"],
        input="\n".join(commands) + "\n", text=True, capture_output=True,
    )
    if selection.returncode:
        return 0
    selected = selection.stdout.rstrip("\n")
    if selected not in commands:
        print("Choose an existing shortcut", file=sys.stderr)
        return 1
    execute(*commands[selected])
    return 0


if __name__ == "__main__":
    sys.exit(main())
