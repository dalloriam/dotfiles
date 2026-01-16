#! /usr/bin/env fish

function is_linux
    if test (uname) = Linux
        return 0
    else
        return 1
    end
end

function is_mac
    if test (uname) = Darwin
        return 0
    else
        return 1
    end
end

function is_arch
    if type -q pacman
        return 0
    else
        return 1
    end
end

function is_ubuntu
    if type -q apt-get
        return 0
    else
        return 1
    end
end

function installed --argument program
    if type -q $program
        return 0
    else
        return 1
    end
end

function ensure_installed --argument program
    if not installed $program
        echo "$program installing"
        ./strap/installers/$program

        # Re-source everything in fish/conf.d
        for file in $__fish_config_dir/conf.d/*.fish
            source $file
        end
    end
end

function symlink_overwrite --argument source --argument target
    if test -e $target
        rm $target
    end

    # We only want to substitute the known variables, not things like `PATH`.
    envsubst "$(cat VARIABLES)" <$source >$target

    # Set the dest executable if the source is executable.
    if test -x $source
        chmod +x $target
    end
end
