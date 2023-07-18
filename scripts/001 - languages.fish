# Setup Rust
if not type -q cargo
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
end

# Setup C/C++
if not type -q clang
    if type -q pacman
        sudo pacman --noconfirm -S clang
    end
end

# Setup Go on ubuntu
if not type -q go
    if test (uname) = Linux
        if type -q apt-get
            set goversion "1.20.2"

            set osarch (uname -m)
            if test $osarch = aarch64
                set arch arm64
            else if test $osarch = x86_64
                set arch amd64
            end

            wget https://go.dev/dl/go$goversion.linux-$arch.tar.gz
            sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go$goversion.linux-$arch.tar.gz
            rm go$goversion.linux-$arch.tar.gz
        end

        if type -q pacman
            sudo pacman --noconfirm -S go
        end
    end
end
