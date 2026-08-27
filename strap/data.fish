source "strap/lib.fish"

function setup_data --argument source_dir
    install_tree $source_dir "$XDG_DATA_HOME/"
end
