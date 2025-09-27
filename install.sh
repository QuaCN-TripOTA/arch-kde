#!/bin/bash
set -e

echo "==> Setup timezone"
ln -sf /usr/share/zoneinfo/Asia/Ho_Chi_Minh /etc/localtime
timedatectl set-timezone Asia/Ho_Chi_Minh
timedatectl set-ntp true

echo "==> Configure locale"
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

echo "==> Hostname"
echo "seiza" > /etc/hostname
if ! grep -q "127.0.0.1 seiza.localdomain seiza" /etc/hosts; then
    echo "127.0.0.1 seiza.localdomain seiza" >> /etc/hosts
fi

echo "==> Setup password for root"
passwd

read -p "Enter your username: " username
echo "==> Create and setup password for user: $username"
useradd -mG wheel "$username"
passwd "$username"

echo "==> Setup wheel"
EDITOR=nano visudo

echo "==> Open /etc/pacman.conf uncomment [multilib] và Include"
nano /etc/pacman.conf

echo "==> Update pacman"
pacman -Syu --noconfirm pacman

echo "==> Open /etc/mkinitcpio.d/linux.preset"
echo "===> Update PRESETS=('default')"
echo "===> #fallback"
nano /etc/mkinitcpio.d/linux.preset
rm -f /boot/initramfs-linux-fallback.img
mkinitcpio -P

echo "==> GRUB Install"
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB

echo "==> Install theme for GRUB"
cd /tmp
git clone https://github.com/vinceliuice/grub2-themes.git
cd grub2-themes
./install.sh -t tela
cd /

echo "==> Config GRUB"
echo "GRUB_DEFAULT=saved"
echo "GRUB_TIMEOUT=2"
echo "GRUB_DISABLE_OS_PROBER=false"
echo "GRUB_DISABLE_SUBMENU=y"
echo "GRUB_DISABLE_RECOVERY=true"
nano /etc/default/grub

chmod -x /etc/grub.d/30_uefi-firmware
grub-mkconfig -o /boot/grub/grub.cfg

echo "==> Install ArchLinux completed!"


echo "==> Install NVIDIA driver"
pacman -S --noconfirm \
    nvidia-dkms nvidia-utils nvidia-settings \
    lib32-nvidia-utils lib32-opencl-nvidia

echo "options nvidia-drm modeset=1" > /etc/modprobe.d/nvidia.conf
echo "blacklist nouveau" > /etc/modprobe.d/blacklist-nouveau.conf

### ==== KDE ====
echo "==> Install KDE and Apps"
pacman -S --noconfirm \
    plasma-meta \
    sddm sddm-kcm \
    konsole dolphin dolphin-plugins spectacle ark gwenview kalk kate okular \
    flatpak pacman-contrib system-config-printer \
    pipewire pipewire-audio pipewire-alsa pipewire-jack wireplumber \
    bluez bluez-utils bluedevil \
    powerdevil power-profiles-daemon \
    ufw ufw-extras \
    kvantum-qt5 fastfetch fish \
    fcitx5-im fcitx5-configtool fcitx5-unikey \
    ttf-roboto ttf-dejavu ttf-liberation ttf-jetbrains-mono \
    noto-fonts noto-fonts-cjk noto-fonts-emoji \
    docker docker-compose

systemctl enable sddm
systemctl enable NetworkManager
systemctl enable bluetooth
systemctl enable ufw
systemctl enable systemd-timesyncd
systemctl enable docker
systemctl enable fstrim.timer

usermod -aG docker licons

echo "==> Install KDE and Apps completed!"
