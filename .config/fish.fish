if status is-interactive
    # Commands to run in interactive sessions can go here
end

alias t="nohup ptyxis --working-directory . --tab >/dev/null 2>&1 &"
alias cd="z"
alias ls="eza --icons always --color always --long --git --no-filesize --no-time --no-user --no-permissions"

fish_add_path /usr/local/go/bin
fish_add_path $HOME/bins

starship init fish | source
fzf --fish | source
zoxide init fish | source

export FZF_CTRL_T_OPTS="
    --style full
    --walker-skip .git,node_modules,target
    --preview 'bat -n --color always {}'
    --bind 'ctrl-/:change-preview-window(down|hidden|)'
"

function fish_greeting
    fastfetch
end