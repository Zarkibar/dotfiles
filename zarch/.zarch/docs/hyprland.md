# NOT BEING ABLE TO SCREENSHARE
Your hyprland xdg portal probably isn't active. Just write the command below and it should be active.
```bash
systemctl --user start xdg-desktop-portal-hyprland
```
NOTE: Make sure to not write ```sudo``` since it's a user specific command and not system. Also don't try to `enable` it. It's not meant to be enabled and has to be initialized from D-Bus

# RealtimeKit
If you see something like `Failed to load RealtimeKit property: GDBus.Error:org.freedesktop.DBus.Error.ServiceUnknown: The name is not activatable` that means rtkit is not installed or started. Just install it from pacman and restart `xdg-desktop-portal`
```bash
sudo pacman -S rtkit
systemctl --user restart xdg-desktop-portal
```

# Better way to fix these desktop portal issues.
Install the uwsm package. Then always login with Hyprland (uwsm-manager) from your login manager.
```bash
sudo pacman -S uwsm
```


# Temporary Fix For The Desktop Portal Issues
```bash
systemctl --user start xdg-desktop-portal-hyprland
systemctl --user start hyprland-session.target
systemctl --user restart xdg-desktop-portal
```

If you see an error saying `hyprland-session.target` does not exist, Write these commands below.
```bash
mkdir -p ~/.config/systemd/user
cat > ~/.config/systemd/user/hyprland-session.target << 'EOF'
[Unit]
Description=Hyprland compositor session
BindsTo=graphical-session.target
Wants=graphical-session-pre.target
After=graphical-session-pre.target
EOF
```

ISSUES: Might cause some your apps to change themes
