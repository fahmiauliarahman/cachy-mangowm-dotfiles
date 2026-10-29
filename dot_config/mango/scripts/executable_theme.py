#!/usr/bin/env python3
"""Switch MangoWM's Quattro palettes without installing Omarchy or Hyprland.

Chezmoi's managed Nord configs are the canonical templates. Switching retints
those configs from the templates (never from the previously selected theme).
"""

import fcntl
import glob
import json
import os
from pathlib import Path
import re
import signal
import subprocess
import sys
import tempfile
import tomllib

HOME = Path.home()
CONFIG = Path(os.environ.get("XDG_CONFIG_HOME", HOME / ".config"))
STATE = Path(os.environ.get("XDG_STATE_HOME", HOME / ".local/state")) / "mango"
THEMES = CONFIG / "mango/themes"
CURRENT = STATE / "theme"
FILES = (
    "mango/cfg/appearance.conf",
    "mango/scripts/power.sh",
    "mango/scripts/screenshot.sh",
    "mango/scripts/radios.py",
    "waybar/style.css",
    "fuzzel/fuzzel.ini",
    "mako/config",
    "kitty/kitty.conf",
    "qt6ct/colors/mango.conf",
    "btop/themes/mango.theme",
    "ohmyposh/mango.omp.json",
    "gtk-3.0/settings.ini",
)
REQUIRED = (
    "accent", "selection", "muted", "background", "dark_background",
    "darker_background", "lighter_background", "foreground",
    "dark_foreground", "light_foreground", "bright_foreground",
    "red", "yellow", "green", "cyan", "blue", "magenta",
)
# Exact upstream Omarchy Quattro Nord palette, including the semantic ramp.
NORD = dict(zip(REQUIRED, (
    "#81a1c1", "#434c5e", "#4c566a", "#2e3440", "#222730",
    "#191c23", "#3b4252", "#d8dee9", "#667080", "#adb5c4",
    "#d8dee9", "#bf616a", "#ebcb8b", "#a3be8c", "#88c0d0",
    "#81a1c1", "#b48ead",
)))


def palettes():
    result = {}
    for file in THEMES.glob("*.toml"):
        if file.is_symlink():
            continue
        try:
            palette = tomllib.loads(file.read_text())
            if palette.get("mode") not in ("dark", "light") or any(
                not re.fullmatch(r"#[0-9a-fA-F]{6}", palette.get(key, ""))
                for key in REQUIRED
            ):
                raise ValueError("expected a complete colors.toml palette")
            result[file.stem] = palette
        except (OSError, ValueError, TypeError) as error:
            print(f"Ignoring {file}: {error}", file=sys.stderr)
    return result


def render(template, palette):
    # Match hexadecimal tokens in CSS, INI, JSON and MangoWM 0xRRGGBBAA.
    # A lookup by color rather than by role handles Nord's repeated colors.
    colors = {}
    for key, value in NORD.items():
        colors.setdefault(value[1:], palette[key][1:])
    token = re.compile(r"(?<![0-9a-fA-F])(?:#|0x)?(?:" + "|".join(
        re.escape(color) for color in sorted(colors, key=len, reverse=True)
    ) + r")(?:ff|ee|88|aa)?(?![0-9a-fA-F])", re.IGNORECASE)

    def recolor(match):
        value = match.group()
        prefix = "0x" if value.startswith("0x") else "#" if value.startswith("#") else ""
        color = value[len(prefix):]
        replacement = colors.get(color[:6].lower())
        return prefix + replacement + color[6:] if replacement else value

    return token.sub(recolor, template)


def source_file(path):
    result = subprocess.run(
        ["chezmoi", "cat", str(path)], capture_output=True, text=True, check=True
    )
    return result.stdout


def replace_file(path, content):
    fd, name = tempfile.mkstemp(prefix=".theme-", dir=path.parent)
    try:
        if path.exists():
            os.fchmod(fd, path.stat().st_mode & 0o777)
        else:
            os.fchmod(fd, 0o600)
        with os.fdopen(fd, "w") as stream:
            stream.write(content)
        os.replace(name, path)
    finally:
        if os.path.exists(name):
            os.unlink(name)


def retint_kitty():
    # All listening instances, not just the terminal that opened the picker.
    runtime = os.environ.get("XDG_RUNTIME_DIR", f"/run/user/{os.getuid()}")
    sockets = set()
    for socket in glob.glob(f"{runtime}/mango-kitty-*"):
        if not os.path.exists(socket):
            continue
        sockets.add(int(socket.rsplit("-", 1)[-1]))
        subprocess.run(
            ["kitten", "@", "--to", f"unix:{socket}", "set-colors", "--all", "--configured",
             str(CONFIG / "kitty/kitty.conf")],
            check=False, timeout=3,
        )
    # Older Kitty windows started before the socket setting still reload the
    # changed config on SIGUSR1. Only processes owned by this user are touched.
    processes = subprocess.run(["pgrep", "-u", str(os.getuid()), "-x", "kitty"],
                               capture_output=True, text=True, check=False)
    for pid in processes.stdout.splitlines():
        if int(pid) not in sockets:
            try:
                os.kill(int(pid), signal.SIGUSR1)
            except ProcessLookupError:
                pass


def activate(name, palette):
    # Render all files before modifying any. A missing template fails cleanly.
    rendered = {CONFIG / rel: render(source_file(CONFIG / rel), palette) for rel in FILES}
    gtk = CONFIG / "gtk-3.0/settings.ini"
    rendered[gtk] = rendered[gtk].replace(
        "gtk-application-prefer-dark-theme=1",
        "gtk-application-prefer-dark-theme=" + ("1" if palette["mode"] == "dark" else "0"),
    )
    for path, content in rendered.items():
        replace_file(path, content)
    STATE.mkdir(parents=True, exist_ok=True)
    previous = CURRENT.read_text() if CURRENT.exists() else None
    CURRENT.write_text(name + "\n")
    try:
        subprocess.run([str(CONFIG / "mango/scripts/wallpaper.sh"), "next"], check=True)
    except (OSError, subprocess.CalledProcessError):
        if previous is None:
            CURRENT.unlink()
        else:
            CURRENT.write_text(previous)
        raise
    replace_file(STATE / "theme.json", json.dumps(palette))
    subprocess.run(["mmsg", "dispatch", "reload_config"], check=False)
    subprocess.run(["makoctl", "reload"], check=False)
    retint_kitty()
    subprocess.run(["pkill", "-x", "waybar"], check=False)
    subprocess.Popen(["waybar"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
                     start_new_session=True)
    print(f"Theme: {name} (open Kitty and Neovim windows retinted)")


def main():
    available = palettes()
    if not available:
        print(f"No palettes found in {THEMES}", file=sys.stderr)
        return 1
    if len(sys.argv) == 2 and sys.argv[1] == "--list":
        print("\n".join(sorted(available)))
        return 0
    if len(sys.argv) == 2 and sys.argv[1] == "--current":
        print(CURRENT.read_text().strip() if CURRENT.exists() else "nord")
        return 0
    if len(sys.argv) == 2 and sys.argv[1] == "--restore":
        if not CURRENT.exists() or CURRENT.read_text().strip() == "nord":
            return 0
        name = CURRENT.read_text().strip()
    elif len(sys.argv) == 3 and sys.argv[1] == "--set":
        name = sys.argv[2]
    elif len(sys.argv) == 1:
        choice = subprocess.run(
            ["fuzzel", "--dmenu", "--prompt", "theme  ", "--lines", "12"],
            input="\n".join(sorted(available)) + "\n", text=True,
            capture_output=True,
        )
        if choice.returncode:
            return 0
        name = choice.stdout.strip()
    else:
        print("usage: theme.py [--list|--current|--restore|--set NAME]", file=sys.stderr)
        return 2
    if name not in available:
        print(f"Unknown theme: {name}", file=sys.stderr)
        return 2
    STATE.mkdir(parents=True, exist_ok=True)
    with (STATE / "theme.lock").open("w") as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        activate(name, available[name])
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except (OSError, subprocess.CalledProcessError) as error:
        print(f"Theme switch failed: {error}", file=sys.stderr)
        sys.exit(1)
