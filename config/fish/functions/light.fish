function light -d "Set light theme"
    set -xU theme light
    kitty @ set-colors -a ~/.config/kitty/catppuccin_latte.conf
end
