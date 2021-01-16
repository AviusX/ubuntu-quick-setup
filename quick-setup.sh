#!/usr/bin/env bash

DEFAULT="\e[0m"
DEFAULTBOLD="\e[1m"

RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"

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
fi

username=$1

# Update and upgrade
apt update && apt upgrade -y

# Install Git
echo -e "${BLUE}[+] Installing Git${DEFAULT}"
apt install -y git

# Install Gnome Tweaks
echo -e "${BLUE}[+] Installing Gnome Tweaks${DEFAULT}"
apt install -y gnome-tweaks

# Install Brave Browser
echo -e "${BLUE}[+] Installing Brave Browser${DEFAULT}"

apt install -y apt-transport-https curl gnupgcurl -s https://brave-browser-apt-release.s3.brave.com/brave-core.asc | apt-key --keyring /etc/apt/trusted.gpg.d/brave-browser-release.gpg add -

echo "deb [arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main" | tee /etc/apt/sources.list.d/brave-browser-release.list

apt update
apt install -y brave-browser

# Install common utils
echo -e "${BLUE}[+] Installing neovim${DEFAULT}"
apt install -y nvim 

# Install snap garbage
echo -e "${BLUE}[+] Installing VLC${DEFAULT}"
snap install vlc

# Install Alacritty
echo -e "${BLUE}[+] Building and installing Alacritty${DEFAULT}"

apt-get install -y cmake pkg-config libfreetype6-dev libfontconfig1-dev libxcb-xfixes0-dev python3
cd /home/$username/Downloads; git clone https://github.com/alacritty/alacritty/
cd alacritty; cargo build --release
cp target/release/alacritty /usr/local/bin
cp extra/logo/alacritty-term.svg /usr/share/pixmaps/Alacritty.svg
desktop-file-install extra/linux/Alacritty.desktop
update-desktop-database

rm -rf /home/$username/Downloads/alacritty
cd /home/$username

# Download custom alacritty config-
echo -e "${BLUE}[+] Customizing Alacritty${DEFAULT}"

git clone https://github.com/AviusX/dotfiles avius-dotfiles
mv /home/$username/avius-dotfiles/alacritty.yml /home/$username/.alacritty.yml
chown $username /home/$username/.alacritty.yml
rm -rf /home/$username/avius-dotfiles

# Create the themes and icons folders-
mkdir /home/$username/.themes /home/$username/.icons
chown -R $username /home/$username/.themes; chown -R $username /home/$username/.icons

# Open GRUB theme preview website-
echo -e "\n${DEFAULTBOLD}Note: In the next step, you will be prompted to choose a GRUB theme. A website will open where you can preview each theme before choosing one for yourself.${DEFAULT}"
read -n 1 -s -r -p "Press any key to continue..."

echo -e "${BLUE}[+] Opening website for theme preview...${DEFAULT}"
xdg-open 'https://github.com/vinceliuice/grub2-themes' &

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
echo -e "${GREEN}[*] DONE! Welcome to Linux and enjoy your fresh install!${DEFAULT}"
