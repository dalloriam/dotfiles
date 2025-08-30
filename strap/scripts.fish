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
    mkdir -p $HOME/bin

    for file_path in (find $source_dir/* -type f)
        if not is_my_platform $file_path
            continue
        end

        set --local src_path (realpath $file_path)

        # Remove $source_dir from the file path
        set --local file_name (echo $file_path | sed "s|$source_dir/||")
        set --local stripped (strip_path $file_name)

        set --local tgt_path $HOME/bin/$stripped

        symlink_overwrite $src_path $tgt_path
        chmod +x $tgt_path
        echo $stripped
    end
end
