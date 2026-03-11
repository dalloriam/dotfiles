# === Git ===
alias gst = git status
alias ga = git add
alias gc = sd git commit
alias gcp = sd git commit-push

# === Navigation (typo fixes) ===
alias sl = ls
alias l = ls
alias s = ls
alias clera = clear
alias celar = clear

# Use exa if available (note: shadows nushell's structured `ls` built-in)
if (which exa | is-not-empty) {
    alias ls = exa --git -F
}

# Use bat if available
if (which bat | is-not-empty) {
    alias cat = bat
}

# === Editor ===
alias vim = nvim

# === System opener (xopen avoids shadowing nushell's built-in `open`) ===
# Use `xopen <path>` to open files/URLs in their default application.
def xopen [...args: string] {
    for opener in [browser-exec xdg-open cmd.exe cygstart start] {
        if (which $opener | is-not-empty) {
            run-external $opener ...$args
            return
        }
    }
    error make { msg: "No suitable file opener found" }
}

# === Tools ===
alias buck2 = buckle
alias vl = vidlib
