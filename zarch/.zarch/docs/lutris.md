# Lutris Setup Guide for Arch Linux (Windows Games via Installer EXE)

## Goal

Set up Lutris on Arch Linux to run Windows games installed from standalone `.exe` installers.

---

# 1. Enable Multilib

Open pacman configuration:

```bash
sudo nano /etc/pacman.conf
```

Ensure the following section is uncommented:

```ini
[multilib]
Include = /etc/pacman.d/mirrorlist
```

Update package databases:

```bash
sudo pacman -Syu
```

---

# 2. Install Lutris and Wine

Install the core packages:

```bash
sudo pacman -S \
lutris \
wine \
winetricks \
vulkan-tools
```

---

# 3. Install Graphics Drivers

## AMD GPU

```bash
sudo pacman -S \
mesa \
lib32-mesa \
vulkan-radeon \
lib32-vulkan-radeon
```

## Intel GPU

```bash
sudo pacman -S \
mesa \
lib32-mesa \
vulkan-intel \
lib32-vulkan-intel
```

## NVIDIA GPU

```bash
sudo pacman -S \
nvidia-utils \
lib32-nvidia-utils
```

---

# 4. Verify Vulkan

Check Vulkan support:

```bash
vulkaninfo --summary
```

A successful output should contain something similar to:

```text
GPU0:
deviceName = AMD Radeon ...
```

If Vulkan works, DXVK can be used by Lutris.

---

# 5. Verify 32-bit Libraries

Lutris requires both 64-bit and 32-bit libraries.

If Lutris reports:

```text
i386 libGL.so.1 missing
i386 libvulkan.so.1 missing
i386 libgnutls.so.30 missing
```

install:

```bash
sudo pacman -S \
lib32-mesa \
lib32-vulkan-radeon \
lib32-gnutls
```

Replace `lib32-vulkan-radeon` with the Intel or NVIDIA equivalent if using a different GPU.

---

# 6. Debug Lutris

Launch Lutris with debugging enabled:

```bash
lutris -d
```

Check for:

```text
ERROR
DXVK
Vulkan
```

Any missing library errors must be resolved before gaming.

---

# 7. Install Wine-GE

Open:

```text
Lutris → Preferences → Runners → Wine
```

Select:

```text
Manage Versions
```

Install the latest:

```text
Wine-GE
```

Wine-GE generally provides the best compatibility for standalone Windows game installers.

---

# 8. Configure Recommended Runner Settings

Open:

```text
Game → Configure → Runner Options
```

Enable:

```text
DXVK     = ON
VKD3D    = ON
Esync    = ON
Fsync    = ON
```

These settings improve performance and compatibility.

---

# 9. Install a Windows Game

Open Lutris.

Click:

```text
+ → Add locally installed game
```

or

```text
+ → Install a Windows game from an executable
```

Configure:

### Runner

```text
Wine
```

### Installer

Select the game's installer executable:

```text
setup.exe
installer.exe
game_installer.exe
```

Choose a dedicated Wine prefix such as:

```text
~/Games/Lutris/GameName
```

Run the installer normally.

---

# 10. Point Lutris to the Game EXE

After installation:

```text
Game → Configure → Game Options
```

Set:

```text
Executable
```

to the actual game executable, not the installer.

Example:

```text
Game.exe
```

instead of:

```text
setup.exe
```

---

# 11. Force AMD GPU (Optional)

For systems with both Intel and AMD GPUs:

```text
Game → Configure → System Options
```

Add environment variable:

```text
DRI_PRIME=1
```

This forces the game to run on the AMD GPU.

Verify:

```bash
DRI_PRIME=1 vulkaninfo --summary
```

---

# 12. Verify Which GPU Renders the Desktop

Install:

```bash
sudo pacman -S mesa-utils
```

Check:

```bash
glxinfo -B | grep "OpenGL renderer"
```

Expected:

```text
OpenGL renderer string: AMD Radeon ...
```

If Intel is shown, consider:

* Using `DRI_PRIME=1`
* Setting the AMD GPU as primary in BIOS
* Disabling the Intel iGPU in BIOS (optional)

---

# Troubleshooting

## Vulkan Works but Lutris Says It Doesn't

Check:

```bash
lutris -d
```

Look for:

```text
i386 libvulkan.so.1 missing
```

This usually means:

* Multilib is not enabled
* 32-bit Vulkan packages are missing

Install the required `lib32-*` packages.

---

## Verify Installed Vulkan Packages

```bash
pacman -Q | grep vulkan
```

---

## Verify Installed 32-bit Packages

```bash
pacman -Q | grep lib32
```

---

## Refresh Package Databases

```bash
sudo pacman -Syyu
```

---

# Recommended Directory Layout

```text
~/Games/
└── Lutris/
    ├── Game1/
    ├── Game2/
    └── Game3/
```

Use one Wine prefix per game to avoid dependency conflicts.

---

# Final Checklist

* [ ] Multilib enabled
* [ ] System updated
* [ ] Lutris installed
* [ ] Wine installed
* [ ] Winetricks installed
* [ ] Vulkan working
* [ ] 32-bit libraries installed
* [ ] Wine-GE installed
* [ ] DXVK enabled
* [ ] VKD3D enabled
* [ ] Game installed successfully
* [ ] AMD GPU selected (optional)

Lutris is now ready for running Windows games installed from standalone installer executables.

