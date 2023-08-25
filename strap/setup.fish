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

function dotfiles
    echo
    echo
    echo "=== Dotfiles ==="
    source "strap/dotfiles.fish"
    setup_dotfiles "./dotfiles"
end


function tools
    echo
    echo "=== Tools Setup ==="
    source "strap/tools.fish"
    setup_tools
end

function scripts
    echo
    echo "=== Userscripts Setup ==="
    source "strap/scripts.fish"
    setup_scripts "./scripts"
end

function neovim
    echo
    echo "=== Neovim Setup ==="
    source "strap/neovim.fish"
    setup_neovim
end

function all
    fonts
    config
    dotfiles
    tools
    scripts
    neovim
end

switch $argv[1]
    case fonts
        fonts
    case config
        config
    case dotfiles
        dotfiles
    case scripts
        scripts
    case tools
        tools
    case neovim
        neovim
    case ""
        all
    case "*"
        echo "Usage: ./strap.sh [fonts|config|tools|dotfiles|scripts|neovim|all]"
end

echo "Setup complete!"
