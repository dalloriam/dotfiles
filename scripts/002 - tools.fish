if not type -q starship
    echo "starship is not installed"
    curl --proto '=https' --tlsv1.2 -sSf https://starship.rs/install.sh | sudo sh -s -- -y
    echo "starship installation complete"
end

if not type -q zoxide
    echo "zoxide is not installed"
    cargo install zoxide
    echo "zoxide installation complete"
end

# Github CLI
if not type -q gh
    if type -q apt-get
        # We're on ubuntu
        set arch (dpkg --print-architecture)
        curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
        echo "deb [arch=$arch signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null
        sudo apt update
        sudo apt install gh
    else if test (uname) = Darwin
        # We're on mac
        brew update
        brew install gh
    else
        echo "No supported platform found for Github CLI"
    end
end
