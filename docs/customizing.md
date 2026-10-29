# Customization and everyday usage

## Start safely

This repository targets CachyOS with MangoWM already installed. The first apply
can install and remove packages, and change the login shell. Review the source
before applying it:

```bash
chezmoi init fahmiauliarahman/omarchy
chezmoi diff
chezmoi apply -v
```

The GitHub repository currently has an `omarchy` slug; that is only its source
URL, not the target operating system.

Package installation uses `sudo pacman`; AUR packages require `paru` or `yay`.
Log out and back in if shell or desktop changes do not appear immediately.

## Add or remove applications

Edit `.chezmoidata.yaml` in the source directory returned by `chezmoi
source-path`:

```yaml
apps:
  arch:
    - foot
  aur:
    - bruno-bin
  remove:
    - chromium
```

Use `apps.arch` for official Arch packages, `apps.aur` for AUR packages, and
`apps.remove` for packages that should be absent. The package script chooses
`paru` or `yay` for AUR packages and uses `pacman` for repository packages.

The `dbx-bin` AUR package installs DBX, the database client. `dbeaver` remains
in `apps.remove`, so applying the package script removes DBeaver if installed.
Review removals carefully: pacman may remove dependencies no longer needed by
other packages. Apply changes with:

```bash
chezmoi apply -v
```

The package script runs again whenever its rendered contents change.

## Change the desktop

The main customization points are:

| Source path | Purpose |
| --- | --- |
| `dot_config/mango/` | MangoWM settings, keybindings, and session scripts |
| `dot_config/waybar/` | Status bar modules and styling |
| `dot_config/mako/` | Notifications |
| `dot_config/fish/` | Shell environment, abbreviations, functions, and plugins |
| `dot_config/mise/` | Development runtime versions |
| `dot_config/nvim/` | LazyVim configuration |
| `dot_config/mimeapps.list` | Default browser and URL handlers |

Edit source files directly with `chezmoi edit`, for example:

```bash
chezmoi edit ~/.config/mango/cfg/keybinds.conf
chezmoi apply ~/.config/mango/cfg/keybinds.conf
```

Reload MangoWM after changing its configuration with the configured reload
keybinding (`Super+R`).

## Desktop workflow

The desktop follows the [Omarchy Quattro themes](https://github.com/omacom/omarchy/tree/quattro/themes), implemented with MangoWM-native tags, layouts, IPC, and keybindings. The built-in theme switcher includes all 23 upstream palettes and their 98 wallpapers; it does not install Omarchy's shell. Use `Super+K` for human-readable shortcut names. `Super+Ctrl+Return` opens Herdr rather than Tmux.

| Keys | Action |
| --- | --- |
| `Super+Space` | Application launcher (Fuzzel) |
| `Super+Escape` / `Super+Ctrl+P` | Lock, suspend, log out, reboot, or shut down |
| `Super+Ctrl+L` | Lock |
| `Super+Ctrl+T` | Select a Quattro palette |
| `Super+Ctrl+A/B/N` | Audio, Bluetooth, or Wi-Fi |
| `Super+Ctrl+C` / `Print` | Capture menu / region screenshot |
| `Super+Ctrl+V` / `Super+V` | Clipboard history; selection copies text or images to the clipboard |
| `Super+Ctrl+W` | Next wallpaper |
| `Super+1–9` / `Super+Shift+1–9` | View tag / move window to tag |
| `Super+L` / `Super+Alt+L` | Cycle native tile, scroller, and dwindle layouts |
| `Super+R` | Reload MangoWM configuration |

Clipboard history runs separate text and image `wl-paste --watch cliphist store` instances. `Super+Ctrl+V` opens a searchable GTK picker with image thumbnails; selecting an entry copies its original text/image MIME to the clipboard. Paste with the application's normal shortcut. Omarchy's universal `Super+C/X/V` injection and Hyprland-only shell features are **not** installed; `Super+V` opens the same history picker. Color selection requires ImageMagick; Wi-Fi/Bluetooth panels require PyGObject, GTK 3, GTK Layer Shell, NetworkManager, and BlueZ utilities. The radio panels have an explicit × button and dismiss with Escape or a click outside the card; known Wi-Fi networks reuse their saved NetworkManager connection.

### Theme switcher

`Super+Ctrl+T` opens the theme menu. `~/.config/mango/scripts/theme.py --list`, `--current`, and `--set tokyo-night` also work from a terminal. The bundled palettes are all 23 themes from Omarchy's Quattro branch, including the five light themes. Add another complete `colors.toml` as `~/.config/mango/themes/NAME.toml` to include it in the menu. This is a palette and wallpaper switcher, not Omarchy's shell or animation machinery.

The switcher renders MangoWM, Waybar, Fuzzel, Mako, Kitty, Qt, btop, Oh My Posh, the lock and radio-panel colors from Chezmoi's canonical Nord source. The clipboard picker and workspace bar read the selected palette. It updates GTK's dark/light preference, reloads MangoWM and Mako, restarts Waybar, retints open Kitty windows, and updates open Neovim editors via a palette state file. Other applications may not support live recoloring; GTK and Qt applications opened after the switch use the new palette. The active name lives in `~/.local/state/mango/theme` and is restored at login. `chezmoi apply` reverts managed files to the canonical Nord source; run `theme.py --set NAME` again to reactivate your selection.

Each bundled palette includes all of its [Omarchy Quattro backgrounds](https://github.com/omacom/omarchy/tree/quattro/themes), except optional intro videos. Switching themes selects its first wallpaper. `Super+Ctrl+W` cycles the packaged images and any files you place under `~/.local/share/mango/wallpapers/<theme>/`; `wallpaper.sh set /path/to/image` still sets an arbitrary image. The theme switcher picks its own theme's wallpaper again on the next switch.

## Save live configuration changes

If a file was edited under `~/.config` rather than through `chezmoi edit`, copy
it back into the source state:

```bash
chezmoi add ~/.config/mango ~/.config/waybar ~/.config/fish
chezmoi diff
```

Then publish the source changes:

```bash
chezmoi cd
git status
git add .
git commit -m "Update CachyOS MangoWM configuration"
git push
```

Do not add credentials, private keys, access tokens, browser profiles, or
device-specific application data.

## Sync another device

Pull the repository and apply it in one step:

```bash
chezmoi update -v
```

Use `chezmoi apply` for source changes already present on the current device;
it does not fetch commits from GitHub.

## Useful checks

Preview unapplied changes:

```bash
chezmoi diff
```

Show the source repository location:

```bash
chezmoi source-path
```

Connect to a hidden Wi-Fi network:

```bash
nmcli device wifi connect "YOUR_SSID" hidden yes
```
