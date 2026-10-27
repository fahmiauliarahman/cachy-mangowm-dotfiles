# CachyOS MangoWM Dotfiles

My personal CachyOS desktop and development setup, managed with
[chezmoi](https://www.chezmoi.io/). MangoWM is the Wayland compositor; this
repository configures it alongside Waybar, Fish, Git, mise, Neovim, and other
daily tools.

## What It Changes

- Installs DBX (`dbx-bin`) from the AUR for database work
- Installs selected Arch and AUR packages, removes selected packages, and sets up MangoWM runtime tools
- Configures MangoWM, Waybar, Fish, Git, mise, Neovim, and LazyGit
- Adds MangoWM scripts for session actions, screenshots, clipboard, Wi-Fi, and wallpapers
- Keeps credentials, browser data, and machine-generated backups out of Git

This is a personal chezmoi configuration, not an OS installer. It targets
CachyOS with MangoWM already installed. Review [`.chezmoidata.yaml`](.chezmoidata.yaml)
and the [`run_*` scripts](run_onchange_before_10-install-apps.sh.tmpl) before
applying: package installation/removal uses `sudo`, AUR packages require `paru`
or `yay`, and another script may change the login shell to Fish.

## Install

On a CachyOS MangoWM system with chezmoi installed:

```bash
chezmoi init --apply fahmiauliarahman/omarchy
```

The GitHub repository currently has an `omarchy` slug; that is only its source
URL, not the target operating system. Fork it and initialize from your fork.

## Keep Devices In Sync

Pull and apply the latest version before making changes:

```bash
chezmoi update -v
```

After editing a managed file, import it into the source repository with
`chezmoi add`, review with `chezmoi diff`, then commit and push from
`chezmoi cd`.

See [Customization and everyday usage](docs/customizing.md) for package
management, configuration changes, syncing, and troubleshooting.

## Hidden Wi-Fi

Connect to a hidden network with:

```bash
nmcli device wifi connect "YOUR_SSID" hidden yes
```
