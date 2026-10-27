# Customization and everyday usage

## Start safely

This repository assumes an existing Omarchy installation. The first apply can
install and remove packages, remove web apps, and change the login shell. To
inspect a checkout before applying it:

```bash
omarchy pkg add chezmoi
chezmoi init fahmiauliarahman/omarchy
chezmoi diff
chezmoi apply -v
```

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
webapps:
  remove:
    - YouTube
```

Use `apps.arch` for official Arch packages, `apps.aur` for AUR packages, and
`apps.remove` for packages that should be absent. Apply the change with:

```bash
chezmoi apply -v
```

The package script runs again whenever its rendered contents change.

## Change the desktop

The main customization points are:

| Source path | Purpose |
| --- | --- |
| `dot_config/hypr/` | Monitors, input, bindings, gaps, windows, and autostart |
| `dot_config/omarchy/shell.json` | Bar layout, clock, idle, and lock settings |
| `dot_config/omarchy/plugins/` | Customized Omarchy Shell plugins |
| `dot_config/omarchy/hooks/` | Actions triggered by Omarchy events |
| `dot_config/fish/config.fish` | Shell environment, abbreviations, and functions |
| `dot_config/mise/config.toml` | Development runtime versions |
| `dot_config/nvim/` | LazyVim configuration |
| `dot_config/mimeapps.list` | Default browser and URL handlers |

Edit source files directly with `chezmoi edit`, for example:

```bash
chezmoi edit ~/.config/hypr/monitors.lua
chezmoi apply ~/.config/hypr/monitors.lua
```

Restart Omarchy Shell after changing its layout or plugins:

```bash
omarchy restart shell
```

The plugin apply script fills in unmodified files from Omarchy's bundled
plugins. Files kept in this repository always take precedence.

## Save live configuration changes

If a file was edited under `~/.config` rather than through `chezmoi edit`, copy
it back into the source state:

```bash
chezmoi add ~/.config/hypr
chezmoi add ~/.config/omarchy/shell.json
chezmoi add ~/.config/fish/config.fish
chezmoi diff
```

Then publish the source changes:

```bash
chezmoi cd
git status
git add .
git commit -m "Update Omarchy configuration"
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

List monitor names and modes before editing `monitors.lua`:

```bash
hyprctl monitors all
```
