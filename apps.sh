#!/bin/bash

set -e

# Cập nhật hệ thống
yay -Syu --noconfirm

# Cài các phần mềm khác
yay -S --noconfirm \
  tela-circle-icon-theme \
  zen-browser-bin \
  nodejs npm jdk-openjdk \
  onedrive onedrivegui \
  vlc \
  libreoffice-fresh \
  teams-for-linux \
  rider \
  dbeaver \
  postman-bin \
  appimagelauncher \
  rclone

echo "==> Cấu hình fcitx5 trong ~/.xprofile"

if ! grep -q "GTK_IM_MODULE=fcitx" ~/.xprofile 2>/dev/null; then
cat << 'EOF' >> ~/.xprofile

# Fcitx5 input method
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS="@im=fcitx"
export INPUT_METHOD=fcitx
EOF
fi

echo "Copy cấu hình Fish"
sudo cp -fr ./fish ~/.config/

echo "Copy Kvantum"
sudo tar -xJf ./Kvantum/Layan.tar.xz -C /usr/share/Kvantum/
sudo tar -xJf ./Kvantum/Layan-solid.tar.xz -C /usr/share/Kvantum/
sudo tar -xJf ./Kvantum/Sweet.tar.xz -C /usr/share/Kvantum/
sudo tar -xJf ./Kvantum/Sweet-Ambar-Blue.tar.xz -C /usr/share/Kvantum/
sudo tar -xJf ./Kvantum/Sweet-Mars.tar.xz -C /usr/share/Kvantum/
sudo tar -xJf ./Kvantum/Sweet-Mars-transparent-toolbar.tar.xz -C /usr/share/Kvantum/
sudo tar -xJf ./Kvantum/Sweet-transparent-toolbar.tar.xz -C /usr/share/Kvantum/

echo "Hoàn tất cài đặt!"
