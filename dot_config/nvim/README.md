# Neovim Configuration

A [LazyVim](https://www.lazyvim.org/)-based Neovim setup, managed with chezmoi. It layers a
curated set of LazyVim's official language extras on top of the framework defaults, plus a
Catppuccin theme and a handful of ergonomic keymaps.

## Features

- Catppuccin Mocha with transparent editor and floating windows
- Go support with `gopls`, `gofumpt`, and `goimports`
- Python and Django support with `basedpyright`, Ruff, and Django template highlighting
- PHP support with `intelephense`
- Laravel navigation and completion with `blade-nav.nvim`
- TypeScript support using `tsgo`
- React JavaScript snippets such as `rafce`, expanded with LuaSnip
- YAML editing with `yamlls`, schema validation via SchemaStore, and formatting
- TOML editing with `taplo`
- Dockerfile and Compose editing with `dockerls`, `docker_compose_language_service`, and
  `hadolint` diagnostics
- LSP inlay hints enabled by default
- Git integration through Gitsigns
- Animations and automatic plugin update checks disabled

## Language Support

| Language / File | LSP / Tooling |
| --- | --- |
| Go | `gopls`, `gofumpt`, `goimports` |
| Python | `basedpyright`, Ruff (format + organize imports) |
| PHP | `intelephense` |
| TypeScript | `tsgo` |
| YAML | `yamlls` (SchemaStore-backed validation and formatting) |
| TOML | `taplo` |
| Dockerfile, `compose.yaml`/`docker-compose.yaml` | `dockerls`, `docker_compose_language_service`, `hadolint` |
| Django templates | `htmldjango` filetype and Treesitter parser |

## Installation

Apply the configuration through chezmoi:

```bash
chezmoi apply ~/.config/nvim
```

Open Neovim and let lazy.nvim install the plugins:

```bash
nvim
```

## Custom Keymaps

`<leader>` is `Space`.

| Key | Mode | Action |
| --- | --- | --- |
| `Ctrl-d` | Normal | Scroll half a page down and center the cursor |
| `Ctrl-u` | Normal | Scroll half a page up and center the cursor |
| `Tab` | Normal | Open the next buffer |
| `Shift-Tab` | Normal | Open the previous buffer |
| `jj` or `JJ` | Insert | Return to Normal mode |
| `n` / `N` | Normal | Move between search results and center the cursor |
| `Ctrl-a` | Normal | Select the entire buffer |
| `Ctrl-/` | Normal or Visual | Toggle comments |
| `<leader>r` | Visual | Replace text inside the selection |
| `<leader>ba` | Normal | Delete all buffers |
| `<leader>gp` | Normal | Preview the current Git hunk |
| `<leader>gt` | Normal | Toggle current-line Git blame |

## Signature Help

LSP signature help opens automatically near the cursor and moves above it when there is not enough room below.
The popup is limited to 80 columns by 12 lines.

Use these keys while the popup is visible:

| Key | Action |
| --- | --- |
| `Ctrl-f` | Scroll the popup down |
| `Ctrl-b` | Scroll the popup up |

Press `Ctrl-k` in Insert mode to open signature help manually.
