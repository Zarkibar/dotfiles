A `.jar` file is already an executable Java application, but Linux doesn't automatically treat it like a normal desktop app. You can create a launcher so it appears in your application menu.

1. Put the JAR somewhere permanent
For example:
```
mkdir -p ~/Applications/AppName
mv AppName.jar ~/Applications/AppName/
```
(Use the actual filename.)

2. Create a launch script
Create:
```
nano ~/Applications/AppName/start.sh
```
Contents:
```
#!/bin/bash
java -jar "$HOME/Applications/AppName/AppName.jar"
```
Make it executable:
```
chmod +x ~/Applications/AppName/start.sh
```
Test it:
```
~/Applications/AppName/start.sh
```

3. Create a desktop entry
Create:
```
nano ~/.local/share/applications/appName.desktop
```
Contents:
```
[Desktop Entry]
Version=1.0
Type=Application
Name=AppName
Comment=Minecraft Launcher
Exec=/home/YOUR_USERNAME/Applications/AppName/start.sh
Icon=minecraft
Terminal=false
Categories=Game;
```
Replace `YOUR_USERNAME` with your username.

A more portable version is:
```
Exec=sh -c "$HOME/Applications/AppName/start.sh"
```

4. Refresh desktop database (optional)
```
update-desktop-database ~/.local/share/applications
```
Or simply log out and back in.

5. Add a custom icon (optional)
Download a PNG icon:
```
~/Applications/AppName/icon.png
```
Then change:
```
Icon=/home/YOUR_USERNAME/Applications/AppName/icon.png
```
