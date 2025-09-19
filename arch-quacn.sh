#!/bin/bash
set -e

# Thiết lập timezone
echo "==> Thiết lập timezone"
ln -sf /usr/share/zoneinfo/Asia/Ho_Chi_Minh /etc/localtime
timedatectl set-timezone Asia/Ho_Chi_Minh
timedatectl set-ntp true

# Cấu hình locale
echo "==> Cấu hình locale"
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

# Hostname
echo "==> Hostname"
echo "tripota" > /etc/hostname
if ! grep -q "127.0.0.1 tripota.localdomain tripota" /etc/hosts; then
    echo "127.0.0.1 tripota.localdomain tripota" >> /etc/hosts
fi

# Thiết lập mật khẩu root
echo "==> Đặt mật khẩu root"
passwd

# Tạo user mới
useradd -mG wheel quacn
echo "==> Đặt mật khẩu cho user: quacn"
passwd quacn

# Sudoers
echo "==> Mở file sudoers để bỏ comment các dòng liên quan đến wheel"
EDITOR=nano visudo

# Pacman multilib
echo "==> Mở /etc/pacman.conf để bỏ comment [multilib] và Include"
nano /etc/pacman.conf

# Update pacman
pacman -Syu --noconfirm pacman

# mkinitcpio chỉnh preset
echo "==> Mở /etc/mkinitcpio.d/linux.preset và chỉnh PRESETS=('default'), comment fallback"
nano /etc/mkinitcpio.d/linux.preset
rm -f /boot/initramfs-linux-fallback.img
mkinitcpio -P

# Cài grub EFI
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB

# Cài theme cho grub
cd /tmp
git clone https://github.com/vinceliuice/grub2-themes.git
cd grub2-themes
./install.sh -t tela
cd /

# Cấu hình grub
echo "==> Mở /etc/default/grub và chỉnh lại:"
echo "GRUB_DEFAULT=saved"
echo "GRUB_TIMEOUT=2"
echo "GRUB_DISABLE_OS_PROBER=false"
echo "GRUB_DISABLE_SUBMENU=y"
echo "GRUB_DISABLE_RECOVERY=true"
nano /etc/default/grub

chmod -x /etc/grub.d/30_uefi-firmware
grub-mkconfig -o /boot/grub/grub.cfg

echo "==> Hoàn tất cấu hình cơ bản!"


echo "==> Cài driver NVIDIA"
pacman -S --noconfirm \
    nvidia-dkms nvidia-utils nvidia-settings \
    lib32-nvidia-utils lib32-opencl-nvidia

echo "options nvidia-drm modeset=1" > /etc/modprobe.d/nvidia.conf
echo "blacklist nouveau" > /etc/modprobe.d/blacklist-nouveau.conf

### ==== KDE ====
echo "==> Cài KDE và các apps"
pacman -S --noconfirm \
    plasma-meta \
    sddm sddm-kcm \
    konsole dolphin dolphin-plugins spectacle ark gwenview kcalc okular \
    plasma-discover packagekit-qt5 flatpak \
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

usermod -aG docker quacn

echo "==> Hoàn tất cài đặt!"
