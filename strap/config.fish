source "strap/lib.fish"

set CONFIG_DIR = "$HOME/.config"

function setup_config --argument source_dir
    for file_path in (find $source_dir/* -type f)
        # Remove $source_dir from the file path
        set --local file_name (echo $file_path | sed "s|$source_dir/||")
        echo $HOME/.config/$file_name
    end
end
