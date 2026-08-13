$env.config.keybindings = ($env.config.keybindings | append {
    name: fuzzy_file
    modifier: control
    keycode: char_t
    mode: [emacs, vi_normal, vi_insert]
    event: {
        send: executehostcommand
        cmd: "commandline edit --insert $'\"(fd | fzf | str trim)\"'"
    }
})

$env.config.keybindings = ($env.config.keybindings | append {
    name: proj_vim
    modifier: control
    keycode: char_p
    mode: [emacs, vi_normal, vi_insert]
    event: {
        send: executehostcommand
        cmd: "proj pick-cli"
    }
})

$env.config.keybindings = ($env.config.keybindings | append {
    name: proj_vim
    modifier: control
    keycode: char_o
    mode: [emacs, vi_normal, vi_insert]
    event: {
        send: executehostcommand
        cmd: "proj pick-gui"
    }
})
