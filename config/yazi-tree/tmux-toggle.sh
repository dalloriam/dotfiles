#!/bin/sh
# Toggle yazi as a file tree on the left of the current tmux pane, in its
# directory; bound to C-n in ~/.tmux.conf. The tmux counterpart of the
# `files` action in ~/.config/rex/init.lua. The sidebar is marked with the
# pane option @files so the next toggle finds it.

files=$(tmux list-panes -F '#{pane_id} #{@files}' | awk '$2 == 1 { print $1; exit }')
if [ -n "$files" ]; then
    tmux kill-pane -t "$files"
    exit
fi

dir=$(tmux display-message -p '#{pane_current_path}')
cmd="$HOME/.config/yazi-tree/start.sh"
[ "$(tmux display-message -p '#{pane_current_command}')" = mxvim ] && cmd="$cmd --mxvim"
pane=$(tmux split-window -hb -l 20% -c "$dir" -P -F '#{pane_id}' "$cmd")
tmux set-option -p -t "$pane" @files 1
