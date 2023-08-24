#! /usr/bin/env fish

echo "Hello from Fish!"


echo
echo "=== Fonts ==="
source "strap/fonts.fish"
setup_fonts "./fonts"
setup_fonts "./private/fonts"

echo
echo
echo "=== Config ==="
source "strap/config.fish"
setup_config "./config"
setup_config "./private/config"

echo
echo "=== Tools Setup ==="
source "strap/tools.fish"
setup_tools
