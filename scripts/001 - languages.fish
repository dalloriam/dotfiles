# Setup Rust
if not type -q cargo
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
end

# Setup Go
if test (uname) = Linux
    set goversion "1.17.7"

    if test (uname -m) = aarch64
        set arch arm64
    else
        set arch (uname -m)
    end

    wget https://go.dev/dl/go$goversion.linux-$arch.tar.gz
    sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go$goversion.linux-$arch.tar.gz
end
