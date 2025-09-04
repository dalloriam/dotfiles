source "strap/lib.fish"

function is_my_platform --argument filepath
    if string match -q -r _ $filepath
        if is_linux && string match -q -r linux $filepath
            return 0
        end

        if is_mac && string match -q -r macos $filepath
            return 0
        end

        return 1
    end

    return 0
end

function strip_path --argument filepath
    if string match -q -r _ $filepath
        if is_linux
            echo (string replace -r linux_ "" $filepath)
        else if is_mac
            echo (string replace -r macos_ "" $filepath)
        end
    else
        echo $filepath
    end
end

function setup_scripts --argument source_dir
    mkdir -p $HOME/scripts
    for file_path in (find $source_dir/* -type f)
        set --local src_path (realpath $file_path)

        set --local file_name (echo $file_path | sed "s|$source_dir/||")
        set --local tgt_path $HOME/scripts/$file_name

        # Create the directory if it doesn't exist
        mkdir -p (dirname $tgt_path)

        symlink_overwrite $src_path $tgt_path
        chmod +x $tgt_path
        echo $file_name
    end
end
