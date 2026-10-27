-- Keep only your personal keybinding overrides here. Add new bindings or
-- unbind defaults before replacing them.

-- See current bindings and descriptions:
--   omarchy menu keybindings --print

-- To disable every Omarchy default binding, set this in
-- ~/.config/hypr/hyprland.lua before require("default.hypr.omarchy"), then add
-- only the bindings you want below:
--   omarchy_default_bindings = false

-- To disable all preinstalled app/webapp bindings, set:
--   omarchy_preinstalled_bindings = false

-- Add a new binding.
-- o.bind("SUPER + SHIFT + R", "SSH", "alacritty -e ssh your-server")

-- Change an existing binding by unbinding it first, then binding the key again.
-- This example changes SUPER+SPACE from the launcher to the Omarchy root menu.
-- hl.unbind("SUPER + SPACE")
-- o.bind("SUPER + SPACE", "Omarchy menu", "omarchy-menu toggle root")

-- Disable a default binding without replacing it.
-- hl.unbind("SUPER + SHIFT + B")

-- Remove default bindings for web apps removed in .chezmoidata.yaml.
-- Google Maps
hl.unbind("SUPER + SHIFT + S")
-- Google Messages
hl.unbind("SUPER + SHIFT + CTRL + G")
-- Google Photos
hl.unbind("SUPER + SHIFT + P")
-- HEY Calendar
hl.unbind("SUPER + SHIFT + C")
-- HEY Email
hl.unbind("SUPER + SHIFT + E")
-- HEY New Email
hl.unbind("SUPER + SHIFT + ALT + E")
-- X
hl.unbind("SUPER + SHIFT + X")
-- X Post
hl.unbind("SUPER + SHIFT + ALT + X")
-- YouTube
hl.unbind("SUPER + SHIFT + Y")
-- Tmux terminal
hl.unbind("SUPER + ALT + RETURN")
-- Tmux keybindings
hl.unbind("SUPER + ALT + K")

-- Omawrite was removed; use its shortcut for WhatsApp.
hl.unbind("SUPER + SHIFT + W")
o.bind("SUPER + SHIFT + W", "WhatsApp", { webapp = "https://web.whatsapp.com/", focus = true })

-- Capture a region with Flameshot.
hl.unbind("SUPER + SHIFT + code:18")
o.bind("SUPER + SHIFT + 9", "Flameshot screenshot", "env XDG_CURRENT_DESKTOP=sway flameshot gui")

-- Replace Omarchy's default screenshot tool with Flameshot.
hl.unbind("PRINT")
o.bind("PRINT", "Flameshot screenshot", "env XDG_CURRENT_DESKTOP=sway flameshot gui")

-- Logitech MX Keys examples:
-- o.bind("SUPER + H", nil, "voxtype record toggle")
-- o.bind("SUPER + PERIOD", nil, "omarchy-shell shell toggle omarchy.emojis")
