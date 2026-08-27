source "strap/lib.fish"

function setup_dotfiles --argument source_dir
    install_tree $source_dir "$HOME/."
end
