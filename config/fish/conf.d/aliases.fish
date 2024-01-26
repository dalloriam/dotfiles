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

if type -q exa
    alias ls "exa --git -F"
end


# Editor stuff
alias vim nvim

for opener in browser-exec xdg-open cmd.exe cygstart start open
    if type -q $opener
        alias open $opener
        break
    end
end

# Tools
alias bazel bazelisk
alias buck2 buckle
