#!/usr/bin/env bash
if command -v apt-get &> /dev/null
then
    # We're on ubuntu/debian
    echo "Setting up prerequisites"
    sudo apt-get update
    sudo apt-get install -y build-essential fish wget
fi

# TODO: Add more mac prereqs
unamestr=$(uname)
if [[ "$unamestr" == 'Darwin' ]]; then
    # Setup brew
    if ! command -v brew &> /dev/null
    then
        echo "Installing brew"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
fi

# TODO: Add script to setup github-cli && op-cli
