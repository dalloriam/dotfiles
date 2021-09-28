#!/usr/bin/env bash

if ! command -v <the_command> &> /dev/null
then
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        cargo install nu
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        # Mac OSX
        brew install nushell
    fi
fi

