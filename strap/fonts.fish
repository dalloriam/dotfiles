source "strap/lib.fish"

function font_directory
    if is_linux
        echo "$HOME/.local/share/fonts"
    else if is_mac
        echo "$HOME/Library/Fonts"
    end
end

function setup_fonts --argument source_dir
    set --local dest_dir (font_directory)

    mkdir -p $dest_dir

    for font_dir in (find $source_dir/* -type d -maxdepth 0)
        set --local font_name (basename $font_dir)
        echo $font_name
        cp -r $font_dir $dest_dir
    end

    if is_ubuntu
        echo "Updating font cache..."
        sudo fc-cache -fv
    end
end
