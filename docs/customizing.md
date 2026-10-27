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
