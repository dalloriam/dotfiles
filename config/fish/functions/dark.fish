function dark -d "Set dark theme"
    set -xU theme dark
    kitty @ set-colors -a ~/.config/kitty/catppuccin_macchiato.conf
end
