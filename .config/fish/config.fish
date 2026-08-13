# --- General Settings ---
set -g fish_greeting ""
set -gx BAT_THEME base16

# --- Aliases ---
alias cat='bat'
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias vencord='sh -c "$(curl -sS https://raw.githubusercontent.com/Vendicated/VencordInstaller/main/install.sh)"'

# --- Interactive Session Config ---
if status is-interactive
    # Visuals
    fastfetch

    # --- FZF.FISH Plugin Configuration ---
    bind \ct 'fd -t f -H -E .git | fzf | read -l result; and commandline -i $result'

    # ПРЯМОЙ БИНД ДЛЯ ИСТОРИИ (Ctrl+R)
    bind \cr 'history | fzf | read -l result; and commandline -r $result'

    # Global FZF defaults
    set -gx FZF_DEFAULT_COMMAND 'fd --type f -H -E .git'
    set -gx FZF_CTRL_T_COMMAND "$FZF_DEFAULT_COMMAND"
end

# --- Functions ---

# Yazi wrapper: change directory on exit
function y
    set tmp (mktemp -t "yazi-cwd.XXXXXX")
    command yazi $argv --cwd-file="$tmp"
    if read -z cwd <"$tmp"; and [ "$cwd" != "$PWD" ]; and test -d "$cwd"
        builtin cd -- "$cwd"
    end
    rm -f -- "$tmp"
end

# --- Final Checks ---
# Created by `pipx` on 2026-02-14 11:59:54
set -gx PATH $PATH /home/user/.local/bin
