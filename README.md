# Clean Omarchy

My small, reproducible [Omarchy](https://omarchy.org/) 4 (Quattro) setup, managed with
[chezmoi](https://www.chezmoi.io/). It removes apps I do not use, installs my
daily tools, and keeps the desktop and development environment consistent
across devices.

## What It Changes

- Installs selected Arch and AUR packages and removes unwanted defaults
- Removes unused Omarchy web apps and their Hyprland keybindings
- Configures Hyprland, Omarchy Shell, Fish, Git, mise, Neovim, and LazyGit
- Adds a compact bar, custom shell plugins, smaller gaps, rounded corners, and
  natural touchpad scrolling
- Keeps credentials, browser data, and machine-generated backups out of Git

This is a personal configuration, not an Omarchy installer. Omarchy must
already be installed. Review [`.chezmoidata.yaml`](.chezmoidata.yaml) and the
[`run_*` scripts](run_onchange_before_10-install-apps.sh.tmpl) before applying:
the setup installs and removes packages, may ask for `sudo`, and changes the
login shell to Fish.

## Install

On one of my new Omarchy devices:

```bash
omarchy pkg add chezmoi
chezmoi init --apply fahmiauliarahman/omarchy
```

Anyone else should fork the repository, adjust the app lists and personal
configuration, then initialize chezmoi from that fork instead.

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
