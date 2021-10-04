# Git
alias gst "git status"
alias ga "git add"
alias gc "git commit -m"

# Navigation
alias sl ls
alias l ls
alias s ls
alias clera clear
alias celar clear
alias ls exa --git


# Editor stuff
alias vim nvim

for opener in browser-exec xdg-open cmd.exe cygstart "start" open
    if type -q $opener
        alias open $opener
        break
    end
end

# Tools
alias ag rg # Want to use ripgrep, like ag bindings.
alias bazel bazelisk
