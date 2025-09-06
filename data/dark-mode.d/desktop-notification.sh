#! /usr/bin/env fish
gsettings set org.gnome.desktop.interface gtk-theme Arc-Dark

niri msg action do-screen-transition && gsettings set org.gnome.desktop.interface color-scheme prefer-dark

makoctl mode -s dark

ln -sf "$HOME"/.config/fuzzel/dark.ini "$HOME"/.config/fuzzel/fuzzel.ini

swww img $HOME/pictures/wallpaper/dark.png

notify-send --app-name="darkman" --urgency=low --icon=weather-clear "switching to dark mode"
