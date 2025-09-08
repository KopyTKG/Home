# !/bin/bash

# Check if the script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit
fi

# Update pacman database
pacman -Syu --noconfirm
if [ $? -ne 0 ]; then
  echo "Failed to update pacman database"
  exit 1
fi 


# ------------------------------------------
# Chaotic AUR

# Check if chaotic-aur is not set up the install it
if ! grep -q "\[chaotic-aur\]" /etc/pacman.conf; then
 # Setup chaotic-aur repository
 sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
 if [ $? -ne 0 ]; then
   echo "Failed to receive chaotic-aur key"
   exit 1
 fi
 sudo pacman-key --lsign-key 3056513887B78AEB
 if [ $? -ne 0 ]; then
   echo "Failed to add chaotic-aur key"
   exit 1
 fi
 
 sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst'
 if [ $? -ne 0 ]; then
   echo "Failed to install chaotic-aur keyring"
   exit 1
 fi
 
 sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'
 if [ $? -ne 0 ]; then
   echo "Failed to install chaotic-aur mirrorlist"
   exit 1
 fi
 
 # Enable chaotic-aur repository if not already enabled
 if ! grep -q "\[chaotic-aur\]" /etc/pacman.conf; then
   echo -e "\n[chaotic-aur]\nInclude = /etc/pacman.d/chaotic-mirrorlist" >> /etc/pacman.conf
   pacman -Sy --noconfirm chaotic-keyring chaotic-mirrorlist
   if [ $? -ne 0 ]; then
     echo "Failed to install chaotic-aur keyring and mirrorlist"
     exit 1
   fi
 fi
fi

# ------------------------------------------
# Multilib Repository

# Enable multilib repository if not already enabled
if ! grep -q "\[multilib\]" /etc/pacman.conf; then
  echo -e "\n[multilib]\nInclude = /etc/pacman.d/mirrorlist" >> /etc/pacman.conf
  pacman -Sy --noconfirm
  if [ $? -ne 0 ]; then
    echo "Failed to update pacman database after enabling multilib"
    exit 1
  fi
fi

# ------------------------------------------
# YAY AUR helper

# Check if dependencies are installed
if ! pacman -Qi --noconfirm git base-devel &> /dev/null; then
  pacman -S --noconfirm git base-devel
  if [ $? -ne 0 ]; then
    echo "Failed to install git and base-devel"
    exit 1
  fi
fi

# Clone yay repository
if [ ! -d /tmp/yay ]; then
  git clone https://aur.archlinux.org/yay.git /tmp/yay
  if [ $? -ne 0 ]; then
    echo "Failed to clone yay repository"
    exit 1
  fi
fi

# Build and install yay
cd /tmp/yay
makepkg -si --noconfirm
if [ $? -ne 0 ]; then
  echo "Failed to build and install yay"
  exit 1
fi

# Clean up
cd ~
rm -rf /tmp/yay

# Synchronize package databases
pacman -Syu --noconfirm
