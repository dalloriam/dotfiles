if not type -q starship
    curl --proto '=https' --tlsv1.2 -sSf https://starship.rs/install.sh >install.sh
    sh ./install.sh -y
    rm install.sh
end
