#! /usr/bin/env fish
function fonts
    echo
    echo "=== Fonts ==="
    source "strap/fonts.fish"
    setup_fonts "./fonts"
    setup_fonts "./private/fonts"
end

function config
    echo
    echo
    echo "=== Config ==="
    source "strap/config.fish"
    setup_config "./config"
    setup_config "./private/config"
end


function tools
    echo
    echo "=== Tools Setup ==="
    source "strap/tools.fish"
    setup_tools
end

function all
    fonts
    config
    tools
end

switch $argv[1]
    case fonts
        fonts
    case config
        config
    case tools
        tools
    case ""
        all
    case "*"
        echo "Usage: ./strap.sh [fonts|config|tools|all]"
end
