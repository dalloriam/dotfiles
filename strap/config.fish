source "strap/lib.fish"

function setup_config --argument source_dir
    install_tree $source_dir "$HOME/.config/"
end
