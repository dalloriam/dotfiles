# Add user stuff
set PATH $PATH ~/bin  # Add user binarires to path

set CXX (which clang++)

# === PYTHON ===
set -x WORKON_HOME $HOME/.virtualenvs
set PATH ~/.local/bin $PATH  # Fix for pip on ubuntu

set -x PYENV_ROOT $HOME/.pyenv
set PATH $PYENV_ROOT/bin $PATH
if type -q pyenv
	pyenv init - | source
end

# === GO ===
if type -q go
	set -x GO111MODULE on
	set -x GOPATH ~
	set PATH $GOROOT/bin $GOPATH/bin $PATH
end

# === JS ===
if type -q yarn
	set PATH (yarn global bin) $PATH
end

# === Rust ===
if test -d ~/.cargo
	set PATH ~/.cargo/bin $PATH
	# TODO: Source ~/.cargo/env somehow
end
