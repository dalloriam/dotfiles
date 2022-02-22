#!/usr/bin/env bash

if ! command -v nu &> /dev/null
then
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        cargo install nu
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        # Mac OSX
        brew install nushell
    fi
fi

SOURCE="${BASH_SOURCE[0]}"
src=$(cd $(dirname $SOURCE)/.. && pwd)/data/nu.toml
tgt=`nu -c "config path"`
rm "$tgt"
mkdir -p "$(dirname $tgt)"
ln -s "$src" "$tgt"
echo "  - linked $src to $tgt"
