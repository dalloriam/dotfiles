if not type -q starship
    curl --proto '=https' --tlsv1.2 -sSf https://starship.rs/install.sh | sudo sh -s -- -y
end
