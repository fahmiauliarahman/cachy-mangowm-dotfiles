#!/usr/bin/python3
"""Wi-Fi and Bluetooth panels, Quattro behavior and Nord colors.

wifi: connected, then other networks with signal bars, then hidden network.
bluetooth: connected, paired, then devices found while scanning.
"""

import atexit
import fcntl
import json
import os
import subprocess
import sys

import gi

gi.require_version("Gtk", "3.0")
gi.require_version("Gdk", "3.0")
gi.require_version("GtkLayerShell", "0.1")
from gi.repository import Gdk, GLib, Gtk, GtkLayerShell

BG = "#222730"
FG = "#d8dee9"
MUTED = "#adb5c4"
ACCENT = "#81a1c1"
LINE = "#4c566a"
CSS = f"""
window {{
  background: transparent;
}}
.panel {{
  background: {BG};
  color: {FG};
  border: 1px solid {LINE};
  border-radius: 2px;
}}
button.row {{
  color: {FG};
  background: {BG};
  padding: 7px 12px;
  border: none;
  border-radius: 2px;
}}
button.row:hover,
button.row:focus {{
  color: {FG};
  background: #3b4252;
}}
button.row:active {{
  color: #191c23;
  background: {ACCENT};
}}
.section {{
  color: {MUTED};
  font-size: 11px;
  padding: 8px 12px 2px 12px;
}}
.title {{
  font-size: 14px;
  padding: 10px 12px 4px 12px;
}}
.dim {{
  color: {MUTED};
}}
.accent {{
  color: {ACCENT};
}}
entry {{
  background: #2e3440;
  color: {FG};
  border: 1px solid {LINE};
  border-radius: 2px;
  padding: 6px 8px;
  margin: 4px 12px 10px 12px;
  caret-color: {FG};
}}
"""


def run(args, timeout=20):
    try:
        out = subprocess.run(args, text=True, capture_output=True, timeout=timeout)
    except subprocess.TimeoutExpired as exc:
        return subprocess.CompletedProcess(args, 124, exc.stdout or "", exc.stderr or "timed out")
    return out


def bars(signal):
    try:
        n = int(signal)
    except (TypeError, ValueError):
        n = 0
    if n >= 80:
        return "▂▄▆█"
    if n >= 60:
        return "▂▄▆▁"
    if n >= 40:
        return "▂▄▁▁"
    if n >= 20:
        return "▂▁▁▁"
    return "▁▁▁▁"


class Panel(Gtk.Window):
    def __init__(self, title):
        super().__init__(type=Gtk.WindowType.TOPLEVEL)
        self.set_can_focus(True)
        self.set_focus_on_map(True)
        self.set_name("panel")
        GtkLayerShell.init_for_window(self)
        GtkLayerShell.set_layer(self, GtkLayerShell.Layer.OVERLAY)
        for edge in (GtkLayerShell.Edge.TOP, GtkLayerShell.Edge.RIGHT,
                     GtkLayerShell.Edge.BOTTOM, GtkLayerShell.Edge.LEFT):
            GtkLayerShell.set_anchor(self, edge, True)
        GtkLayerShell.set_keyboard_mode(self, GtkLayerShell.KeyboardMode.EXCLUSIVE)
        self.connect("key-press-event", self._key)
        self.connect("button-press-event", self._outside_click)

        screen = Gdk.Screen.get_default()
        provider = Gtk.CssProvider()
        provider.load_from_data(CSS.encode())
        Gtk.StyleContext.add_provider_for_screen(
            screen, provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
        )
        backdrop = Gtk.EventBox()
        backdrop.set_visible_window(False)
        backdrop.set_can_focus(False)
        backdrop.connect("button-press-event", self._outside_click)
        self.add(backdrop)
        align = Gtk.Alignment.new(1, 0, 0, 0)
        align.set_padding(42, 0, 0, 10)
        backdrop.add(align)
        self.box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=0)
        self.box.get_style_context().add_class("panel")
        self.box.set_margin_bottom(8)
        align.add(self.box)
        header = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL)
        self.box.pack_start(header, False, False, 0)
        label = Gtk.Label(label=title, xalign=0)
        label.get_style_context().add_class("title")
        header.pack_start(label, True, True, 0)
        close = Gtk.Button(label="×")
        close.set_tooltip_text("Close panel (Escape)")
        close.set_relief(Gtk.ReliefStyle.NONE)
        close.connect("clicked", lambda *_: self.close())
        header.pack_end(close, False, False, 0)
        self.body = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=0)
        self.box.pack_start(self.body, True, True, 0)

    def _outside_click(self, _backdrop, event):
        allocation = self.box.get_allocation()
        origin_x, origin_y = self.box.get_window().get_origin()
        if not (origin_x <= event.x_root < origin_x + allocation.width and
                origin_y <= event.y_root < origin_y + allocation.height):
            self.close()
            return True
        return False

    def close(self):
        self.destroy()
        if Gtk.main_level():
            Gtk.main_quit()

    def _key(self, _win, event):
        if event.keyval == Gdk.KEY_Escape:
            self.close()
            return True
        return False

    def clear(self):
        for child in self.body.get_children():
            self.body.remove(child)

    def section(self, text):
        label = Gtk.Label(label=text, xalign=0)
        label.get_style_context().add_class("section")
        self.body.pack_start(label, False, False, 0)

    def row(self, main, sub, on_click, accent=False):
        button = Gtk.Button()
        button.set_relief(Gtk.ReliefStyle.NONE)
        button.get_style_context().add_class("row")
        box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=12)
        left = Gtk.Label(label=main, xalign=0)
        left.set_hexpand(True)
        left.set_halign(Gtk.Align.START)
        if accent:
            left.get_style_context().add_class("accent")
        right = Gtk.Label(label=sub, xalign=1)
        right.get_style_context().add_class("dim")
        box.pack_start(left, True, True, 0)
        box.pack_start(right, False, False, 0)
        button.add(box)
        button.connect("clicked", lambda *_: on_click())
        self.body.pack_start(button, False, False, 0)

    def status(self, text):
        label = Gtk.Label(label=text, xalign=0)
        label.set_margin_start(12)
        label.set_margin_end(12)
        label.set_margin_top(8)
        label.get_style_context().add_class("dim")
        label.set_line_wrap(True)
        self.body.pack_start(label, False, False, 0)

    def show_all_now(self):
        self.show_all()
        self.present()
        self.grab_focus()


class Wifi(Panel):
    def __init__(self):
        super().__init__("Wi-Fi")
        self.asking = False
        self.status("Scanning…")
        self.show_all_now()
        GLib.idle_add(self.refresh, True)

    def refresh(self, rescan):
        self.clear()
        if rescan:
            run(["nmcli", "device", "wifi", "rescan"], timeout=8)
        raw = run(
            ["nmcli", "-t", "-f", "IN-USE,SSID,SIGNAL,SECURITY", "device", "wifi", "list", "--rescan", "no"]
        ).stdout
        seen = {}
        for line in raw.splitlines():
            parts = line.split(":")
            if len(parts) < 4:
                continue
            use, sec, signal = parts[0], parts[-1], parts[-2]
            ssid = ":".join(parts[1:-2])
            if not ssid or ssid in seen:
                continue
            seen[ssid] = (use == "*", signal, sec)
        connected = [(s, v) for s, v in seen.items() if v[0]]
        rest = sorted(
            ((s, v) for s, v in seen.items() if not v[0]),
            key=lambda item: -int(item[1][1] or 0),
        )
        if connected:
            self.section("Connected: " + ", ".join(ssid for ssid, _ in connected))
            for ssid, (_use, signal, _sec) in connected:
                self.row(ssid, bars(signal) + "  connected", lambda s=ssid: self.disconnect(s), accent=True)
        if rest:
            self.section("Available")
            for ssid, (_use, signal, sec) in rest:
                locked = "  lock" if sec and sec != "--" else ""
                self.row(ssid, bars(signal) + locked, lambda s=ssid, sec=sec: self.join(s, sec))
        if not connected and not rest:
            self.status("No networks found.")
        self.section("")
        self.row("Hidden network", "", self.hidden)
        self.show_all_now()

    def disconnect(self, _ssid):
        devices = run(["nmcli", "-t", "-f", "DEVICE,TYPE,STATE", "device", "status"]).stdout
        for line in devices.splitlines():
            device, kind, state = (line.split(":", 2) + ["", ""])[:3]
            if kind == "wifi" and state.startswith("connected"):
                run(["nmcli", "device", "disconnect", device], timeout=10)
                break
        self.close()

    def join(self, ssid, sec, hidden=False):
        # Activate a saved NetworkManager connection before requesting secrets.
        profiles = run(["nmcli", "-t", "-f", "UUID,TYPE", "connection", "show"]).stdout
        for line in profiles.splitlines():
            uuid, _, kind = line.partition(":")
            if kind not in ("802-11-wireless", "wifi"):
                continue
            saved_ssid = run(["nmcli", "-g", "802-11-wireless.ssid", "connection", "show", "uuid", uuid]).stdout.strip()
            if saved_ssid == ssid:
                self.done(ssid, run(["nmcli", "connection", "up", "uuid", uuid], timeout=25))
                return
        if sec and sec != "--":
            self.ask_password(ssid, hidden)
            return
        args = ["nmcli", "device", "wifi", "connect", ssid]
        if hidden:
            args += ["hidden", "yes"]
        self.done(ssid, run(args, timeout=25))

    def hidden(self):
        self.asking = True
        self.clear()
        self.section("Hidden network")
        ssid = Gtk.Entry()
        ssid.set_placeholder_text("Network name")
        password = Gtk.Entry()
        password.set_placeholder_text("Password")
        password.set_visibility(False)
        self.body.pack_start(ssid, False, False, 0)
        self.body.pack_start(password, False, False, 0)
        self.row("Connect", "", lambda: self._hidden_go(ssid.get_text(), password.get_text()), accent=True)
        self.show_all_now()
        ssid.grab_focus()

    def _hidden_go(self, ssid, password):
        ssid = ssid.strip()
        if not ssid:
            return
        args = ["nmcli", "device", "wifi", "connect", ssid, "hidden", "yes"]
        if password:
            args += ["password", password]
        self.done(ssid, run(args, timeout=25))

    def ask_password(self, ssid, hidden):
        self.asking = True
        self.clear()
        self.section(ssid)
        password = Gtk.Entry()
        password.set_placeholder_text("Password")
        password.set_visibility(False)
        password.connect("activate", lambda w: self._go(ssid, w.get_text(), hidden))
        self.body.pack_start(password, False, False, 0)
        self.row("Connect", "", lambda: self._go(ssid, password.get_text(), hidden), accent=True)
        self.show_all_now()
        password.grab_focus()

    def _go(self, ssid, password, hidden):
        args = ["nmcli", "device", "wifi", "connect", ssid, "password", password]
        if hidden:
            args += ["hidden", "yes"]
        self.done(ssid, run(args, timeout=25))

    def done(self, ssid, result):
        self.asking = False
        if result.returncode == 0:
            self.close()
            return
        self.clear()
        err = (result.stderr or result.stdout or "failed").strip().splitlines()
        self.status(err[-1] if err else "failed")
        self.row("Back", "", lambda: self.refresh(rescan=False))
        self.show_all_now()


class Bluetooth(Panel):
    def __init__(self):
        super().__init__("Bluetooth")
        run(["bluetoothctl", "power", "on"], timeout=6)
        run(["bluetoothctl", "scan", "on"], timeout=3)
        self.refresh()
        GLib.timeout_add_seconds(3, self._tick)

    def _tick(self):
        if not self.get_visible():
            return False
        self.refresh()
        return True

    def refresh(self):
        focus = self.get_focus()
        if isinstance(focus, Gtk.Entry):
            return True
        raw = run(["bluetoothctl", "devices"], timeout=6).stdout
        devices = []
        for line in raw.splitlines():
            parts = line.split(None, 2)
            if len(parts) < 3 or parts[0] != "Device":
                continue
            mac, name = parts[1], parts[2]
            if name == mac:
                continue
            info = run(["bluetoothctl", "info", mac], timeout=4).stdout
            paired = "Paired: yes" in info
            connected = "Connected: yes" in info
            devices.append((mac, name, paired, connected))
        self.clear()
        groups = {
            "Connected": [d for d in devices if d[3]],
            "Paired": [d for d in devices if d[2] and not d[3]],
            "Available": [d for d in devices if not d[2] and not d[3]],
        }
        connected_names = [name for _mac, name, _paired, connected in devices if connected]
        if connected_names:
            self.section("Connected: " + ", ".join(connected_names))
        shown = False
        for title, rows in groups.items():
            if not rows:
                continue
            shown = True
            if title != "Connected":
                self.section(title)
            for mac, name, paired, connected in rows:
                if connected:
                    sub, action = "connected", lambda m=mac: self.act("disconnect", m)
                elif paired:
                    sub, action = "paired", lambda m=mac: self.act("connect", m)
                else:
                    sub, action = "", lambda m=mac: self.act("pair", m)
                self.row(name, sub, action, accent=connected)
        if not shown:
            self.status("Scanning…")
        self.section("")
        self.row("Turn off", "", self.off)
        self.show_all_now()
        return True

    def act(self, action, mac):
        if action == "pair":
            result = run(["bluetoothctl", "--timeout", "12", "pair", mac], timeout=16)
            if result.returncode != 0:
                self.fail(result)
                return
            run(["bluetoothctl", "trust", mac], timeout=6)
            action = "connect"
        result = run(["bluetoothctl", "--timeout", "10", action, mac], timeout=14)
        if result.returncode != 0:
            self.fail(result)
            return
        self.close()

    def fail(self, result):
        err = (result.stderr or result.stdout or "failed").strip().splitlines()
        self.clear()
        self.status(err[-1] if err else "failed")
        self.row("Back", "", self.refresh)
        self.show_all_now()

    def off(self):
        run(["bluetoothctl", "power", "off"], timeout=6)
        self.close()


def main():
    runtime = os.environ.get("XDG_RUNTIME_DIR", f"/run/user/{os.getuid()}")
    lock = open(os.path.join(runtime, "mango-radio-panel.lock"), "w")
    try:
        fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
    except BlockingIOError:
        lock.close()
        return 0
    atexit.register(lock.close)
    kind = sys.argv[1] if len(sys.argv) > 1 else ""
    if kind == "wifi":
        Wifi()
    elif kind == "bluetooth":
        Bluetooth()
    else:
        print("usage: radios.py wifi|bluetooth", file=sys.stderr)
        return 2
    Gtk.main()
    return 0


if __name__ == "__main__":
    sys.exit(main())
