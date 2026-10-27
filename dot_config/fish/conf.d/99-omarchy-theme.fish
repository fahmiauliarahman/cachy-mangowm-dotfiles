# Keep Fish syntax highlighting and Oh My Posh aligned with Omarchy's active theme.
set -l omarchy_colors "$HOME/.local/state/omarchy/current/theme/colors.toml"

if test -f $omarchy_colors
    function __omarchy_color -a name file
        awk -F '"' -v key=$name '$1 ~ "^" key "[[:space:]]*=" { print $2; exit }' $file
    end

    set -l accent (__omarchy_color accent $omarchy_colors)
    set -l foreground (__omarchy_color foreground $omarchy_colors)
    set -l muted (__omarchy_color muted $omarchy_colors)
    set -l red (__omarchy_color bright_red $omarchy_colors)
    set -l green (__omarchy_color green $omarchy_colors)
    set -l yellow (__omarchy_color yellow $omarchy_colors)
    set -l blue (__omarchy_color blue $omarchy_colors)
    set -l cyan (__omarchy_color cyan $omarchy_colors)
    set -l magenta (__omarchy_color magenta $omarchy_colors)

    set -g fish_color_command $accent
    set -g fish_color_keyword $accent
    set -g fish_color_cwd $accent
    set -g fish_color_comment $muted
    set -g fish_color_error $red
    set -g fish_color_normal $foreground
    set -g fish_color_operator $yellow
    set -g fish_color_param $foreground
    set -g fish_color_quote $green
    set -g fish_color_search_match --bold --background=$accent
    set -g fish_color_selection --bold --background=$accent
    set -g fish_color_status $red
    set -g fish_color_user $green

    set -gx OMARCHY_POSH_ACCENT $accent
    set -gx OMARCHY_POSH_FOREGROUND $foreground
    set -gx OMARCHY_POSH_RED $red
    set -gx OMARCHY_POSH_YELLOW $yellow
    set -gx OMARCHY_POSH_GREEN $green
    set -gx OMARCHY_POSH_BLUE $blue
    set -gx OMARCHY_POSH_CYAN $cyan
    set -gx OMARCHY_POSH_MAGENTA $magenta
    set -gx OMARCHY_POSH_MUTED $muted

    functions -e __omarchy_color
end
