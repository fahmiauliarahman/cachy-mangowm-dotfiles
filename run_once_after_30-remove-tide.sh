#!/bin/bash
set -euo pipefail

fish_dir="$HOME/.config/fish"
rm -f "$fish_dir/completions/tide.fish" "$fish_dir/conf.d/_tide_init.fish" "$fish_dir/functions/tide.fish"
rm -f "$fish_dir"/functions/_tide_*.fish
rm -rf "$fish_dir/functions/tide"

if [[ -f "$fish_dir/functions/fish_prompt.fish" ]] && grep -q '_tide_' "$fish_dir/functions/fish_prompt.fish"; then
  rm "$fish_dir/functions/fish_prompt.fish"
fi

fish -c 'set -eU VIRTUAL_ENV_DISABLE_PROMPT; for name in (set -U --names | string match -r "^_?tide"); set -eU $name; end'
