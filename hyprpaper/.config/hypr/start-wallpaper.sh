wallpaper=$(cat ~/.local/share/zarch/config/current-theme)

#hyprctl hyprpaper unload all
hyprctl hyprpaper wallpaper ",$wallpaper"
