#! /usr/bin/env fish
source "strap/lib.fish"

function setup_tools
    for x in strap/installers/*
        set --local program (basename $x)
        echo $program
        ensure_installed $program
    end
end
