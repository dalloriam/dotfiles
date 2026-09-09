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
