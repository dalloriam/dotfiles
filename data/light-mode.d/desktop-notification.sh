#! /usr/bin/env fish

for _ in (seq 1 30)
    swww query >/dev/null 2>&1; and break
    sleep 0.2
end

swww img $HOME/pictures/wallpaper/light.png
sleep 2

gsettings set org.gnome.desktop.interface gtk-theme Adwaita
sed -i 's/^theme ".*"/theme "catppuccin-latte"/' "$HOME"/.config/zellij/config.kdl
niri msg action do-screen-transition && gsettings set org.gnome.desktop.interface color-scheme prefer-light

makoctl mode -r dark

ln -sf "$HOME"/.config/fuzzel/light.ini "$HOME"/.config/fuzzel/fuzzel.ini

notify-send --app-name="darkman" --urgency=low --icon=weather-clear "switching to light mode"
