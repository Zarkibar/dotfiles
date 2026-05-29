#!/bin/bash

# Wallpaper
feh --bg-fill "$HOME/.config/backgrounds/" &

# Notifications
killall dunst && dunst &

# Clipboard history daemon
#greenclip daemon &

# Status bar
killall polybar && polybar main &

# Idle locker
#xautolock -time 10 -locker "$HOME/.config/i3/lock.sh" -detectsleep &
