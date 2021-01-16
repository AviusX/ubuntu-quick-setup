#!/usr/bin/env bash

DEFAULT="\e[0m"
DEFAULTBOLD="\e[1m"

RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
CYAN="\e[36m"

# If script wasn't executed as root, exit
if [[ $(whoami) != "root" ]]; then
	echo -e "${RED}[-] Please run this script as root.${DEFAULT}"
	exit
fi

# If number of arguments are 0, exit
if [[ $# -eq 0 ]]; then
	echo -e "${RED}[-] Please enter your username as the first argument.${DEFAULT}"
	echo "Usage: sudo $0 \$USER"
	exit
fi

# If given user does not exist, exit
if id "$1" &>/dev/null; then
    echo -e "${GREEN}[+] Starting auto setup${DEFAULT}" 
else
    echo -e "${RED}[-] Entered username does not exist. Please check if you entered it correctly.${DEFAULT}" 
    exit
fi

username=$1

# Update and upgrade
echo -e "\n${CYAN}[+] Updating package lists and upgrading software...${DEFAULT}"
apt update && apt upgrade -y

# Install Git
echo -e "\n${CYAN}[+] Installing Git${DEFAULT}"
apt install -y git 1>/dev/null 2>/dev/null

# Install Gnome Tweaks
echo -e "${CYAN}[+] Installing Gnome Tweaks${DEFAULT}"
apt install -y gnome-tweaks 1>/dev/null 2>/dev/null

# Install Brave Browser
echo -e "${CYAN}[+] Installing Brave Browser${DEFAULT}"

apt install -y apt-transport-https curl gnupg 1>/dev/null 2>/dev/null
curl -s https://brave-browser-apt-release.s3.brave.com/brave-core.asc | apt-key --keyring /etc/apt/trusted.gpg.d/brave-browser-release.gpg add -
echo "deb [arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main" | tee /etc/apt/sources.list.d/brave-browser-release.list

apt update 1>/dev/null 2>/dev/null
apt install -y brave-browser 1>/dev/null 2>/dev/null

# Install common utils
echo -e "${CYAN}[+] Installing neovim${DEFAULT}"
apt install -y neovim 1>/dev/null 2>/dev/null

# Install snap garbage
echo -e "${CYAN}[+] Installing VLC${DEFAULT}"
snap install vlc

# Install Alacritty
echo -e "${CYAN}[+] Building and installing Alacritty${DEFAULT}"

apt install -y cargo 1>/dev/null 2>/dev/null
apt install -y cmake pkg-config libfreetype6-dev libfontconfig1-dev libxcb-xfixes0-dev python3 1>/dev/null 2>/dev/null
cd /home/$username/Downloads; git clone https://github.com/alacritty/alacritty/ 1>/dev/null
cd alacritty; cargo build --release
cp target/release/alacritty /usr/local/bin
cp extra/logo/alacritty-term.svg /usr/share/pixmaps/Alacritty.svg
desktop-file-install extra/linux/Alacritty.desktop
update-desktop-database

rm -rf /home/$username/Downloads/alacritty
cd /home/$username

# Make Alacritty the default terminal
echo -e "${CYAN}[+] Setting Alacritty as the default termnal emulator${DEFAULT}"
update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator /usr/local/bin/alacritty 50
echo 0 | update-alternatives --config x-terminal-emulator && echo

# Download custom alacritty config-
echo -e "${CYAN}[+] Customizing Alacritty${DEFAULT}"

git clone https://github.com/AviusX/dotfiles avius-dotfiles 1>/dev/null
mv /home/$username/avius-dotfiles/alacritty.yml /home/$username/.alacritty.yml
chown $username /home/$username/.alacritty.yml
rm -rf /home/$username/avius-dotfiles

# Install Fira Code
echo -e "${CYAN}[+] Installing font firacode${DEFAULT}"
apt install -y fonts-firacode 1>/dev/null 2>/dev/null

# Create the themes and icons folders-
mkdir /home/$username/.themes /home/$username/.icons
chown -R $username /home/$username/.themes; chown -R $username /home/$username/.icons

# Download wallpapers
echo -e "${CYAN}[+] Downloading some pogchamp wallpapers into /home/$username/Pictures/Wallpapers/ ${DEFAULT}"
cd /home/$username/Pictures/; mkdir Wallpapers; cd Wallpapers
wget --quiet -O shooting-star.png https://i.redd.it/m23bwh4n0x151.png
wget --quiet -O astronaut.png https://i.redd.it/h6f70szyude31.png
wget --quiet -O joker.png https://i.redd.it/e7hunasn67641.png
wget --quiet -O cyber-city.jpg https://i.redd.it/c9iwoawbdo861.jpg
wget --quiet -O orange-fantasy.jpg https://i.redd.it/i3wcpwczqjb61.jpg
wget --quiet -O nature-arch.jpg https://i.redd.it/k35ttt1qara61.jpg
wget --quiet -O space-man.jpg https://i.redd.it/598n7rn58gb61.jpg
wget --quiet -O prey-wallpaper.jpg https://i.redd.it/9pczisi1jba61.jpg
chown -R $username /home/$username/Pictures/Wallpapers

# Open GRUB theme preview website-
echo -e "\n${DEFAULTBOLD}Note: In the next step, you will be prompted to choose a GRUB theme. A website will open where you can preview each theme before choosing one for yourself.${DEFAULT}"
read -n 1 -s -r -p "Press any key to continue..."

echo -e "\n\n${CYAN}[+] Opening website for theme preview...${DEFAULT}"
sudo -u $username brave-browser-stable 'https://github.com/vinceliuice/grub2-themes#screenshots' 1>/dev/null 2>/dev/null & 

# Install Grub Theme
echo -e "\n${YELLOW}Available GRUB themes-"
echo -e "1. Vimix"
echo -e "2. Stylish"
echo -e "3. Tela"
echo -e "4. Slaze${DEFAULT}"
echo -n "Please choose which grub theme you want to install (1/2/3/4): "

while true; do
	read theme_number
	case $theme_number in
		1) flag="--vimix"; break; ;;
		2) flag="--stylish"; break; ;;
		3) flag="--tela"; break; ;;
		4) flag="--slaze"; break; ;;
		*) echo -e "${RED}[-] Incorrect choice. Please choose a theme between 1 to 4" ;;
	esac
done

cd /home/$username/Downloads; git clone https://github.com/vinceliuice/grub2-themes grub-theme
cd grub-theme; ./install.sh $flag
rm -rf /home/$username/Downloads/grub-theme

# DONE!
echo -e "\n\n${GREEN}[*] DONE! Welcome to Linux and enjoy your fresh install!${DEFAULT}"
