set -g fish_greeting ""

alias cat='bat'
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias vencord='sh -c "$(curl -sS https://raw.githubusercontent.com/Vendicated/VencordInstaller/main/install.sh)"'

if status is-interactive
    # Commands to run in interactive sessions can go here
	fastfetch
end


function y
	set tmp (mktemp -t "yazi-cwd.XXXXXX")
	command yazi $argv --cwd-file="$tmp"
	if read -z cwd < "$tmp"; and [ "$cwd" != "$PWD" ]; and test -d "$cwd"
		builtin cd -- "$cwd"
	end
	rm -f -- "$tmp"
end

set -gx FZF_DEFAULT_COMMAND 'fd --type f --strip-cwd-prefix --hidden --exclude .git'
set -gx FZF_CTRL_T_COMMAND "$FZF_DEFAULT_COMMAND"

set -gx BAT_THEME "base16"

# Created by `pipx` on 2026-02-14 11:59:54
set PATH $PATH /home/user/.local/bin
