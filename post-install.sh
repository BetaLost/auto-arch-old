#!/bin/bash

# Parse Variable
CHOICE=$1

# Functions
infobox() {
	whiptail --backtitle "Auto Arch" --title "$1" --infobox "$2" 12 0
}

getdesc() { pacman -Si $1 | grep -Po '^Description\s*: \K.+'; }
getsize() { pacman -Si $1 | grep -Po '^Installed Size\s*: \K.+'; }

# Define Packages
PKGS=(
	"lightdm" # Display manager
	"lightdm-webkit2-greeter" # LightDM theme
	"bspwm" # Tiling Window Manager
	"sxhkd" # Hotkey Daemon
	"xf86-video-intel" # Intel Video Driver
	"xorg-server" # X System
	"xorg-xinit" # X System
	"xorg-xinput" # X System
	"xorg-xkill" # X System
	"xorg-xrandr" # X System
	"xorg-xdpyinfo" # X System
	"libwnck3" # X System
	"mesa" # Mesa
	"lib32-mesa" # 32-bit Mesa
	"mesa-demos" # Mesa Demos
	"mesa-utils" # Mesa Utils
	"light" # Manage brightness
	"zsh" # Z Shell
	"cifs-utils" # Mount Common Internet File System
	"ntfs-3g" # Mount New Technology File System
	"rofi" # Search tool
	"flameshot" # Screenshot tool
	"kitty" # Terminal Emulator
	"neovim" # Text Editor
	"nodejs" # TSServer dependency
	"npm" # TSServer dependency
	"typescript-language-server" # TS/JS Server
	"rust-analyzer" # Rust Language Server
	"clang" # C-Family Language Server
	"pyright" # Python Language Server
	"lua-language-server" # Lua Language Server
	"htop" # System monitor
	"exa" # ls alternative
	"bat" # cat alternative
	"wget" # Retrieve content
	"git" # Git
	"man" # Manual
	"github-cli" # Github CLI
	"dunst" # Notifications
	"pulseaudio" # Audio Package
	"pulsemixer" # Audio Package
	"alsa-firmware" # Audio Package
	"alsa-plugins" # Audio Package
	"alsa-utils" # Audio Package
	"rtkit" # Audio Package
	"sof-firmware" # Audio Package
	"pulseaudio-bluetooth" # Bluetooth headset capability
	"zip" # Zip files
	"unzip" # Unzip files
	"feh" # Change wallpaper
	"python-pip" # Install Python modules/packages
	"xclip" # Copy to clipboard
	"ttf-joypixels" # Emoji font
	"libx11" # X11 Client Library
	"libxcursor" # Cursor dependency
	"libpng" # Cursor dependency
	"xorg-xprop" # Polywins dependency
	"wmctrl" # Polywins dependency
	"slop" # Polywins dependency
)

AMD_GPU_PKGS=(
	"vulkan-radeon"
	"lib32-vulkan-radeon"
	"vulkan-icd-loader"
	"lib32-vulkan-icd-loader"
	"xf86-video-amdgpu"
)

NVIDIA_GPU_PKGS=(
	"nvidia"
	"nvidia-utils"
	"nvidia-settings"
	"lib32-nvidia-utils"
	"vulkan-icd-loader"
	"lib32-vulkan-icd-loader"
)

AUR_PKGS=(
	"nerd-fonts-jetbrains-mono" # JetBrains Mono Nerd Font
	"ttf-poppins" # Poppins font
	"picom-ibhagwan-git" # Picom compositor
	"polybar" # Polybar
	"brave-bin" # Brave Browser
)

# Install packages
sudo pacman -Syy &>> /log.txt

getindex() {
	for i in "${!PKGS[@]}"; do
		if [[ "${PKGS[i]}" = "$1" ]]; then echo $(expr $i + 1); fi
	done
}

fastinstall() {
	infobox "Installing packages" "Installing ${#PKGS[@]} packages from the official Arch Linux repositories..."
	sudo pacman -S --noconfirm "${PKGS[@]}" &>> /log.txt
}

slowinstall() {
	for pkg in "${PKGS[@]}"; do
		infobox "Installing packages" "Name: $pkg\nDescription: $(getdesc $pkg)\nSize: $(getsize $pkg)\n$(getindex $pkg) out of ${#PKGS[@]}"
		sudo pacman -S --noconfirm $pkg &>> /log.txt
	done
}

case $CHOICE in
	1) fastinstall;;
	2) slowinstall;;
esac

# Install GPU drivers - Change array name to NVIDIA_GPU_PKGS or AMD_GPU_PKGS depending on your hardware
getindex() {
	for i in "${!NVIDIA_GPU_PKGS[@]}"; do
		if [[ "${NVIDIA_GPU_PKGS[i]}" = "$1" ]]; then echo $(expr $i + 1); fi
	done
}

fastinstall() {
	infobox "Installing packages" "Installing ${#NVIDIA_GPU_PKGS[@]} driver packages for NVIDIA GPU..."
	sudo pacman -S --noconfirm "${NVIDIA_GPU_PKGS[@]}" &>> /log.txt
}

slowinstall() {
	for pkg in "${NVIDIA_GPU_PKGS[@]}"; do
		infobox "Installing packages (GPU)" "Name: $pkg\nDescription: $(getdesc $pkg)\nSize: $(getsize $pkg)\n$(getindex $pkg) out of ${#NVIDIA_GPU_PKGS[@]}"
		sudo pacman -S --noconfirm $pkg &>> /log.txt
	done
}

case $CHOICE in
	1) fastinstall;;
	2) slowinstall;;
esac

# Install AUR packages
for aurpkg in "${AUR_PKGS[@]}"; do
	infobox "AUR" "Installing \"$aurpkg\" from the Arch User Repository..."
	git clone https://aur.archlinux.org/$aurpkg.git &>> /log.txt
        sudo chmod 777 $aurpkg
	cd $aurpkg
	makepkg -si --noconfirm &>> /log.txt
	cd ..
	sudo rm -rf $aurpkg
done

# Install LightDM Aether theme
infobox "LightDM" "Configuring and installing LightDM theme..."
git clone https://github.com/NoiSek/Aether.git &>> /log.txt
sudo mv Aether /usr/share/lightdm-webkit/themes/lightdm-webkit-theme-aether
sudo sed -i 's/^webkit_theme\s*=\s*\(.*\)/webkit_theme = lightdm-webkit-theme-aether #\1/g' /etc/lightdm/lightdm-webkit2-greeter.conf
sudo sed -i "s/#greeter-session=example-gtk-gnome/greeter-session=lightdm-webkit2-greeter/g" /etc/lightdm/lightdm.conf
sudo sed -i "s/#user-session=default/user-session=bspwm/g" /etc/lightdm/lightdm.conf
sudo systemctl enable lightdm.service &>> /log.txt

# Fix default user icon
# sudo cp /usr/share/lightdm-webkit/themes/lightdm-webkit-theme-aether/src/img/default-user.png /var/lib/AccountsService/icons/$USER
# sudo sed -i "s/Icon=\/home\/$USER\/.face/Icon=\/var\/lib\/AccountsService\/icons\/$USER/g" /var/lib/AccountsService/users/$USER

# Change default shell
infobox "Default Shell" "Changing default shell to ZSH..."
sudo chsh -s /bin/zsh $USER &>> /log.txt

# Download dotfiles
infobox "Dotfiles" "Cloning dotfiles repository..."
git clone https://github.com/BetaLost/dotfiles.git &>> /log.txt
mkdir -p $HOME/.config

# Configure BSPWM and SXHKD
infobox "Dotfiles" "Configuring BSPWM and SXHKD..."
sudo mv $HOME/dotfiles/bspwm $HOME/.config/
sudo mv $HOME/dotfiles/sxhkd $HOME/.config/
sudo mv $HOME/dotfiles/wallpapers $HOME/.config/

find $HOME/.config/bspwm -type f -exec chmod +x {} \;
find $HOME/.config/sxhkd -type f -exec chmod +x {} \;

# Configure ZSH
infobox "Dotfiles" "Configuring the Z Shell (ZSH)..."
git clone https://github.com/zsh-users/zsh-autosuggestions.git $HOME/.zsh/zsh-autosuggestions &>> /log.txt
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $HOME/.zsh/zsh-syntax-highlighting &>> /log.txt
mv $HOME/dotfiles/.zshrc $HOME/

# Configure BASH
infobox "Dotfiles" "Configuring the Bourne Again Shell (BASH)..."
mv $HOME/dotfiles/.bashrc $HOME/

# Configure VIM
#infobox "Dotfiles" "Configuring VIM..."
#curl -fLso $HOME/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
#mv $HOME/dotfiles/.vimrc $HOME/
#vim -c "PlugInstall | q | q"
#$HOME/.vim/plugged/YouCompleteMe/install.py --clangd-completer --ts-completer --rust-completer

# Configure Neovim
infobox "Dotfiles" "Configuring Neovim..."
curl -fLo $HOME/.local/share/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
mv $HOME/dotfiles/nvim $HOME/.config/
nvim -c "PlugInstall | q | q"
sed -i "s/background = '#282923'/background = '#1a1a18'/g" $HOME/.local/share/nvim/plugged/ofirkai.nvim/lua/ofirkai/design.lua

# Configure Rofi
infobox "Dotfiles" "Configuring Rofi..."
sudo mv $HOME/dotfiles/rofi $HOME/.config/

# Configure Kitty
infobox "Dotfiles" "Configuring the Kitty terminal emulator..."
sudo mv $HOME/dotfiles/kitty $HOME/.config/

# Configure Picom 
infobox "Dotfiles" "Configuring Picom..."
sudo mv $HOME/dotfiles/picom $HOME/.config/

# Configure Polybar
infobox "Dotfiles" "Configuring Polybar..."
sudo mv $HOME/dotfiles/polybar $HOME/.config/

for script in $HOME/.config/polybar/scripts/*; do
    sudo chmod +x $script
done

# Install Arabic font
infobox "Arabic Font" "Installing Arabic font..."
wget https://github.com/BetaLost/auto-arch/raw/main/khebrat-musamim.zip &>> /log.txt
unzip khebrat-musamim.zip &>> /log.txt
rm khebrat-musamim.zip
sudo mkdir -p /usr/share/fonts/TTF
sudo mv "18 Khebrat Musamim Regular.ttf" /usr/share/fonts/TTF/

sudo mv $HOME/dotfiles/fonts.conf /etc/fonts/
sudo cp /etc/fonts/fonts.conf /etc/fonts/local.conf

# Install GRUB theme
infobox "GRUB Theme" "Installing GRUB theme..."
wget https://github.com/BetaLost/auto-arch/raw/main/arch.tar &>> /log.txt
sudo mkdir -p /boot/grub/themes
sudo mkdir /boot/grub/themes/arch
sudo mv arch.tar /boot/grub/themes/arch/
sudo tar xf /boot/grub/themes/arch/arch.tar -C /boot/grub/themes/arch/
sudo rm /boot/grub/themes/arch/arch.tar
sudo sed -i "s/GRUB_GFXMODE=auto/GRUB_GFXMODE=1920x1080/g" /etc/default/grub
sudo sed -i "s/#GRUB_THEME=.*/GRUB_THEME=\"\/boot\/grub\/themes\/arch\/theme.txt\"/g" /etc/default/grub
sudo grub-mkconfig -o /boot/grub/grub.cfg &>> /log.txt

# Install cursor
infobox "Cursor" "Installing cursor..."
wget https://github.com/BetaLost/auto-arch/raw/main/macOSBigSur.tar.gz &>> /log.txt
tar -xf macOSBigSur.tar.gz
rm macOSBigSur.tar.gz
sudo mv macOSBigSur /usr/share/icons/

sudo sed -i "s/Inherits=Adwaita/Inherits=macOSBigSur/g" /usr/share/icons/default/index.theme

rm -rf $HOME/dotfiles $0
