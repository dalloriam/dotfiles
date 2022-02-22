if not type -q cargo
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
end

# TODO: Add script to setup github-cli && op-cli
