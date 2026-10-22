#!/bin/sh
# Start yazi as the file tree, with this directory as its config (see
# yazi.toml). With --mxvim, in the directory of the file in the session's
# mxvim rather than the pane's; the toggles pass it when Ctrl-n is pressed
# in an mxvim pane.
export YAZI_CONFIG_HOME="$HOME/.config/yazi-tree"
if [ "$1" = --mxvim ] && dir=$(mxvim --dir 2>/dev/null) && [ -d "$dir" ]; then
    cd "$dir"
fi
exec yazi
