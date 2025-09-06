source "strap/lib.fish"

function setup_data --argument source_dir
    for file_path in (find $source_dir/* -type f)

        set --local src_path (realpath $file_path)

        # Remove $source_dir from the file path
        set --local file_name (echo $file_path | sed "s|$source_dir/||")
        set --local tgt_path $XDG_DATA_HOME/$file_name

        # Create the directory if it doesn't exist
        mkdir -p (dirname $tgt_path)

        symlink_overwrite $src_path $tgt_path
        echo $file_name
    end
end
