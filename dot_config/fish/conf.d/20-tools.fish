# mise manages language runtimes such as Node.js.
mise activate fish | source

# Atuin command history and search.
atuin init fish | source

# Use zoxide's database for directory changes, with builtin cd as fallback.
zoxide init fish --cmd cd | source

# Compact replacements for common file commands.
alias cat 'bat --paging=never'
alias ls 'eza'
alias ll 'eza -lh --git'
alias la 'eza -lah --git'
