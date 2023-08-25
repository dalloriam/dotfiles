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

function installed --argument program "Checks if a program is installed"
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
    end
end

function symlink_overwrite --argument source --argument target
    if test -e $target
        rm $target
    end
    ln -s $source $target
end
