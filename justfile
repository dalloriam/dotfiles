clang:
    #! /usr/bin/env fish
    if not type -q clang
        if type -q pacman
            echo "installing clang"
            sudo pacman --noconfirm -S clang
        else
            "no supported platform found for clang"
        end
    else
        echo "clang already installed"
    end

direnv:
    #! /usr/bin/env fish
    if not type -q direnv
        if type -q apt-get
            # We're on ubuntu
            sudo apt install direnv -y
        else if test (uname) = Darwin
            # We're on mac
            brew install direnv
        else
            echo "No supported platform found for direnv"
        end
    end

build:
    cd bootstrap && cargo build

run +args="":
    @just build
    ./bootstrap/target/debug/bootstrap {{args}}

docker:
    docker build -t dalloriam/dotfiles .
