#! /usr/bin/env fish
swww img $HOME/pictures/wallpaper/dark.png
sleep 2
gsettings set org.gnome.desktop.interface gtk-theme Arc-Dark

sed -i 's/^theme ".*"/theme "catppuccin-macchiato"/' "$HOME"/.config/zellij/config.kdl
niri msg action do-screen-transition && gsettings set org.gnome.desktop.interface color-scheme prefer-dark

makoctl mode -s dark

ln -sf "$HOME"/.config/fuzzel/dark.ini "$HOME"/.config/fuzzel/fuzzel.ini

notify-send --app-name="darkman" --urgency=low --icon=weather-clear "switching to dark mode"
