set -gx SHELL /usr/bin/fish
fish_add_path /usr/local/bin ~/.local/bin

if status is-interactive
    set -g fish_greeting

    if command -q oh-my-posh
        oh-my-posh init fish --config ~/.config/ohmyposh/omarchy.omp.json | source
    end

    # Only initialize mise if we aren't ALREADY in a Poetry shell
    if not set -q VIRTUAL_ENV
        mise activate fish | source
    end

    # --- 1. Your Personal Workflow ---
    abbr -a projects "cd ~/Developer/projects"
    abbr -a flick "cd ~/Developer/projects/screen/flick && nvim ."
    abbr -a cfg "cd ~/.config/nvim && nvim ."

    # "cameo" translated for Fish (uses activate.fish)
    abbr -a cameo "cd ~/Developer/projects/screen/screen_cms/ && source .venv/bin/activate.fish"

    # --- 2. Dangerous/Complex Commands ---
    # Note: Fish handles env vars differently in single lines (no export needed for one-off)
    abbr -a clidanger "env ANTHROPIC_BASE_URL=http://127.0.0.1:8317 ANTHROPIC_AUTH_TOKEN=sk-apikey ANTHROPIC_DEFAULT_OPUS_MODEL=gemini-claude-sonnet-4-5-thinking ANTHROPIC_DEFAULT_SONNET_MODEL=gemini-claude-sonnet-4-5-thinking claude --dangerously-skip-permissions"

    # --- 3. Utilities ---
    abbr -a cat bat
    abbr -a _ sudo

    # Eza (ls replacement) - mimicking your old aliases
    abbr -a l "eza -lah"
    abbr -a la "eza -lAh"
    abbr -a ll "eza -al --group-directories-first"
    abbr -a ls "eza -al --color=always --sort=size | grep -v /"
    abbr -a lt "eza -al --sort=modified"

    # --- 4. Poetry Shortcuts ---
    abbr -a pad "poetry add"
    abbr -a prun "poetry run"
    abbr -a psh "poetry shell"
    abbr -a pinst "poetry install"
    abbr -a pup "poetry update"

    # --- 5. zoxide: better cd ---
    abbr -a cd z

    # --- 6. reload fish config ---
    abbr -a reload 'source ~/.config/fish/config.fish'
    abbr -a activate 'source .venv/bin/activate.fish'

end

# --- Functions for complex logic ---

# Function for 'showarch'
function showarch
    echo "Now you are using "(arch)" version"
end

# Your 'git-https' converter translated to a Fish function
function git-https
    set -l url (git remote get-url origin)
    set -l new_url (string replace -r '^git@([^:]*):/*(.*)$' 'https://$1/$2' $url)
    git remote set-url origin $new_url
end

# Your 'git-ssh' converter translated to a Fish function
function git-ssh
    set -l url (git remote get-url origin)
    set -l new_url (string replace -r '^https://([^/]*)/(.*)$' 'git@$1:$2' $url)
    git remote set-url origin $new_url
end
zoxide init fish | source

# PHP version switcher for Fish using mise's asdf backend.
if command -q mise
    function __installed_php_versions --description "List installed PHP major.minor versions"
        mise ls --installed asdf:mise-plugins/asdf-php --json 2>/dev/null \
            | string match -arg '"version": "([0-9]+\.[0-9]+)[^"]*"' \
            | sort -Vu
    end

    function switchphp --description "Switch PHP version (example: switchphp 8.1)"
        set -l requested_version $argv[1]
        if test -z "$requested_version"
            echo "Usage: switchphp <major.minor>"
            set -l versions (__installed_php_versions)
            if test (count $versions) -gt 0
                echo "Installed: "(string join ", " $versions)
            end
            return 1
        end

        if not contains -- $requested_version (__installed_php_versions)
            echo "PHP $requested_version is not installed."
            echo "Use 'installphp $requested_version' to install it."
            return 1
        end

        if not mise use --global --remove php "asdf:mise-plugins/asdf-php@$requested_version"
            echo "Failed to switch to PHP $requested_version."
            return 1
        end

        command php -v | head -n 1
    end

    function installphp --description "Install a new PHP version (example: installphp 8.4)"
        set -l requested_version $argv[1]
        if test -z "$requested_version"
            echo "Usage: installphp <major.minor>"
            set -l versions (__installed_php_versions)
            if test (count $versions) -gt 0
                echo "Installed: "(string join ", " $versions)
            end
            echo -e "\nTo see all available versions: mise ls-remote asdf:mise-plugins/asdf-php"
            return 1
        end

        if contains -- $requested_version (__installed_php_versions)
            echo "PHP $requested_version is already installed."
            switchphp $requested_version
            return $status
        end

        if command -q omarchy
            set -l php_build_dependencies base-devel autoconf bison re2c pkgconf libxml2 openssl icu libzip oniguruma curl libpng libjpeg-turbo freetype2 libwebp gmp libsodium readline bzip2
            set -l missing_dependencies
            for dependency in $php_build_dependencies
                if not pacman -Q $dependency >/dev/null 2>&1
                    set -a missing_dependencies $dependency
                end
            end

            if test (count $missing_dependencies) -gt 0
                echo "Installing PHP build dependencies: "(string join ", " $missing_dependencies)
                if not omarchy pkg add $missing_dependencies
                    echo "Failed to install PHP build dependencies."
                    return 1
                end
            end
        end

        echo "Installing PHP $requested_version via mise's asdf backend..."
        if not mise use --global --remove php "asdf:mise-plugins/asdf-php@$requested_version"
            echo "Failed to install PHP $requested_version."
            return 1
        end

        echo "Successfully installed PHP $requested_version!"
        command php -v | head -n 1
        return
    end

    # Create version functions for all installed versions
    for installed_version in (__installed_php_versions)
        function $installed_version -V installed_version
            switchphp $installed_version
        end
    end
end
eval "$(mise activate fish)"
set -gx GLAB_SKIP_TLS_VERIFY true

# bun
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH
