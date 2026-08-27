source "strap/lib.fish"

function setup_scripts --argument source_dir
    mkdir -p $HOME/scripts
    install_tree $source_dir "$HOME/scripts/" executable
end
