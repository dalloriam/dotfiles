#! /usr/bin/env fish
source "strap/lib.fish"


function install_starship
    curl --proto '=https' --tlsv1.2 -sSf https://starship.rs/install.sh | sudo sh -s -- -y
end

function install_zoxide
    cargo install zoxide
end

function setup_tools
    for x in strap/installers/*
        set --local program (basename $x)
        echo $program
        ensure_installed $program
    end
    echo done
end
