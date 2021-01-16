# Ubuntu Quickrice
###### Description: Quickly set up and customize a fresh Ubuntu installation by automatically installing the essential software and tools using this script. No hassle.

---
### Features

Currently, the script does the following things-
- Upgrades pre-installed packages
- Installs Git
- Installs Gnome Tweaks
- Installs Brave Browser
- Installs neovim
- Installs VLC
- Installs Alacritty and sets it as the default terminal
- Customises Alacritty
- Installs a GRUB theme based on your choice
- Downloads a few wallpapers to ~/Pictures/Wallpapers

### Usage

Simply run the following command, sit back and relax as the script sets up everything for you-
```bash
wget -q https://raw.githubusercontent.com/AviusX/ubuntu-quick-setup/master/quick-setup.sh -O - | sudo bash -s $USER
```
