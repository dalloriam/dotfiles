source "strap/lib.fish"

function setup_dotfiles --argument source_path
    for file_path in (find $source_path/* -type f)
        set --local src_path (realpath $file_path)

        # Remove $source_dir from the file path
        set --local file_name (echo $file_path | sed "s|$source_path/||")

        set --local tgt_path $HOME/.$file_name

        symlink_overwrite $src_path $tgt_path
        echo $file_name
    end
end
