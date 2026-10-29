#!/usr/bin/python3
"""Search clipboard history with real image previews, then copy the selected item."""

import os
from pathlib import Path
import re
import subprocess
import sys
import tomllib

import gi

gi.require_version("Gtk", "3.0")
gi.require_version("Gdk", "3.0")
gi.require_version("GtkLayerShell", "0.1")
from gi.repository import Gdk, GdkPixbuf, Gtk, GtkLayerShell

IMAGE = re.compile(r"\[\[ binary data .*? (?:png|jpe?g|webp|gif|bmp) .*?\]\]", re.I)
HOME = Path.home()
CONFIG = Path(os.environ.get("XDG_CONFIG_HOME", HOME / ".config"))
STATE = Path(os.environ.get("XDG_STATE_HOME", HOME / ".local/state")) / "mango/theme"
name = STATE.read_text().strip() if STATE.exists() else "nord"
if not name or "/" in name or name.startswith("."):
    name = "nord"
palette = tomllib.loads((CONFIG / "mango/themes" / f"{name}.toml").read_text())
CSS = f"""
window, .panel {{ background: {palette['dark_background']}; color: {palette['foreground']}; }}
.panel {{ border: 1px solid {palette['muted']}; border-radius: 2px; }}
entry {{ background: {palette['background']}; color: {palette['foreground']}; border: 1px solid {palette['muted']};
        padding: 8px; margin: 10px; border-radius: 2px; }}
button.row {{ background: {palette['dark_background']}; color: {palette['foreground']}; border: none;
             border-radius: 2px; padding: 6px; }}
button.row:hover, button.row:focus {{ background: {palette['selection']}; }}
label.hint {{ color: {palette['light_foreground']}; }}
""".encode()


def decode(item):
    return subprocess.run(["cliphist", "decode"], input=item.encode(),
                          capture_output=True, check=True).stdout


def items():
    result = subprocess.run(["cliphist", "list"], capture_output=True, text=True, check=True)
    return [line for line in result.stdout.splitlines() if "\t" in line]


class Picker(Gtk.Window):
    def __init__(self):
        super().__init__(title="Clipboard history")
        self.set_decorated(False)
        GtkLayerShell.init_for_window(self)
        GtkLayerShell.set_layer(self, GtkLayerShell.Layer.OVERLAY)
        GtkLayerShell.set_anchor(self, GtkLayerShell.Edge.TOP, True)
        GtkLayerShell.set_anchor(self, GtkLayerShell.Edge.BOTTOM, True)
        GtkLayerShell.set_anchor(self, GtkLayerShell.Edge.LEFT, True)
        GtkLayerShell.set_anchor(self, GtkLayerShell.Edge.RIGHT, True)
        GtkLayerShell.set_margin(self, GtkLayerShell.Edge.TOP, 48)
        GtkLayerShell.set_margin(self, GtkLayerShell.Edge.BOTTOM, 32)
        GtkLayerShell.set_margin(self, GtkLayerShell.Edge.LEFT, 48)
        GtkLayerShell.set_margin(self, GtkLayerShell.Edge.RIGHT, 48)
        GtkLayerShell.set_keyboard_mode(self, GtkLayerShell.KeyboardMode.EXCLUSIVE)
        self.connect("destroy", lambda *_: Gtk.main_quit() if Gtk.main_level() else None)
        self.connect("key-press-event", self.key)
        provider = Gtk.CssProvider()
        provider.load_from_data(CSS)
        Gtk.StyleContext.add_provider_for_screen(Gdk.Screen.get_default(), provider,
                                                  Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION)
        self.get_style_context().add_class("panel")
        self.history = items()
        self.box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL)
        self.add(self.box)
        self.search = Gtk.SearchEntry()
        self.search.set_placeholder_text("Search clipboard history")
        self.search.connect("search-changed", self.refresh)
        self.search.connect("activate", self.first)
        self.box.pack_start(self.search, False, False, 0)
        scroll = Gtk.ScrolledWindow()
        scroll.set_policy(Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC)
        self.box.pack_start(scroll, True, True, 0)
        self.rows = Gtk.Box(orientation=Gtk.Orientation.VERTICAL)
        scroll.add(self.rows)
        self.refresh()
        self.show_all()
        self.search.grab_focus()

    def key(self, _widget, event):
        if event.keyval == Gdk.KEY_Escape:
            self.destroy()
            return True
        return False

    def first(self, _entry):
        for row in self.rows.get_children():
            if isinstance(row, Gtk.Button):
                row.clicked()
                break

    def refresh(self, *_):
        for row in self.rows.get_children():
            self.rows.remove(row)
        query = self.search.get_text().casefold()
        matches = [item for item in self.history if query in item.casefold()][:50]
        for item in matches:
            button = Gtk.Button()
            button.set_relief(Gtk.ReliefStyle.NONE)
            button.get_style_context().add_class("row")
            content = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=12)
            button.add(content)
            if IMAGE.search(item):
                try:
                    data = decode(item)
                    loader = GdkPixbuf.PixbufLoader()
                    loader.write(data)
                    loader.close()
                    pixbuf = loader.get_pixbuf()
                    if pixbuf is not None:
                        scale = min(96 / pixbuf.get_width(), 96 / pixbuf.get_height())
                        scaled = pixbuf.scale_simple(max(1, int(pixbuf.get_width() * scale)),
                                                     max(1, int(pixbuf.get_height() * scale)),
                                                     GdkPixbuf.InterpType.BILINEAR)
                        content.pack_start(Gtk.Image.new_from_pixbuf(scaled), False, False, 0)
                except (subprocess.CalledProcessError, ValueError, TypeError) as error:
                    print(f"Cannot preview clipboard image: {error}", file=sys.stderr)
                label = Gtk.Label(label="Image", xalign=0)
            else:
                label = Gtk.Label(label=item.split("\t", 1)[1], xalign=0)
            label.set_max_width_chars(68)
            label.set_ellipsize(3)
            content.pack_start(label, True, True, 0)
            button.connect("clicked", lambda _button, entry=item: self.select(entry))
            self.rows.pack_start(button, False, False, 0)
        self.rows.show_all()

    def select(self, item):
        data = decode(item)
        match = IMAGE.search(item)
        mime = "text/plain;charset=utf-8"
        if match:
            kind = re.search(r"\b(png|jpeg|jpg|webp|gif|bmp)\b", match.group(), re.I)
            mime = "image/" + ("jpeg" if kind.group(1).lower() == "jpg" else kind.group(1).lower())
        subprocess.run(["wl-copy", "--type", mime], input=data, check=True)
        self.destroy()


def main():
    try:
        Picker()
        Gtk.main()
        return 0
    except (OSError, subprocess.CalledProcessError) as error:
        print(f"Clipboard picker: {error}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())
