function light -d "Set light theme"
    set -xU theme light
    kitty @ set-colors -a ~/.config/kitty/flexoki_light.conf
end
