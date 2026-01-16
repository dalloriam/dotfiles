# Add user stuff
fish_add_path ~/bin
fish_add_path /usr/local/go/bin

set CXX (which clang++)

# === PYTHON ===
set -x WORKON_HOME $HOME/.virtualenvs
fish_add_path ~/.local/bin

# === GO ===
if type -q go
    #set -x GOROOT /usr/local/go
    set -x GO111MODULE on
    set -x GOPATH ~
    fish_add_path $GOPATH/bin
end

# === Rust ===
if test -d ~/.cargo
    fish_add_path ~/.cargo/bin
    # TODO: Source ~/.cargo/env somehow
end
