# Neovim Agent Guide

## Scope

These instructions apply to the `nvim` Stow package.

## Architecture

- `nvim/.config/nvim/init.lua` loads `config.lazy`.
- `lua/config/` contains core options, keymaps, and autocommands.
- `lua/plugins/` contains small LazyVim plugin overrides.
- Language support comes from LazyVim's Go, Python, TypeScript, PHP, YAML, TOML, and Docker
  extras.
- Python uses `basedpyright` and formats with Ruff.
- PHP uses `intelephense`.
- TypeScript uses `tsgo`.
- YAML uses `yamlls` with SchemaStore; TOML uses `taplo`; Dockerfile/Compose use `dockerls`,
  `docker_compose_language_service`, and `hadolint`.
- `lua/config/autocmds.lua` retags `*compose*.yaml`/`.yml` files as `yaml.docker-compose` so
  `docker_compose_language_service` attaches (Neovim's built-in detection only sets plain `yaml`).
- Django templates use the `htmldjango` filetype and Treesitter parser.

## Guidelines

- Prefer LazyVim defaults and official extras over custom configuration.
- Keep overrides minimal and scoped to the plugin they configure.
- Do not add plugins when LazyVim, Neovim, or an installed plugin already provides the behavior.
- Preserve Catppuccin Mocha and transparent editor and floating-window backgrounds.
- Keep animations and automatic plugin update checks disabled.
- Keep `README.md` synchronized when user-facing keymaps or behavior change.

## Signature Help

- Noice automatically opens LSP signature help near the cursor.
- Its popup is limited to 80 columns by 12 lines.
- `Ctrl-f` scrolls the popup down.
- `Ctrl-b` scrolls the popup up.
- `Ctrl-k` opens signature help manually in Insert mode.

## Verification

Run these checks after editing the configuration:

```bash
nvim --headless "+checkhealth" "+qa"
stow -nv -t ~ nvim
git diff --check
```

Confirm plugin-specific resolved options with Lazy's `Plugin.values` when changing merged `opts` tables.
