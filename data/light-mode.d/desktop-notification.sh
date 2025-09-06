#! /usr/bin/env fish
swww img $HOME/pictures/wallpaper/light.png
sleep 2

gsettings set org.gnome.desktop.interface gtk-theme Adwaita
niri msg action do-screen-transition && gsettings set org.gnome.desktop.interface color-scheme prefer-light

makoctl mode -r dark

ln -sf "$HOME"/.config/fuzzel/light.ini "$HOME"/.config/fuzzel/fuzzel.ini

notify-send --app-name="darkman" --urgency=low --icon=weather-clear "switching to light mode"
