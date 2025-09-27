#!/bin/bash

set -e

cd /tmp
git clone https://aur.archlinux.org/yay
cd yay
makepkg -si --noconfirm
cd /tmp/arch-kde

# Cập nhật hệ thống
yay -Syu --noconfirm

# Cài các phần mềm khác
echo "==> Cài đặt phần mềm"
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
read -p "Enter your username: " username
cat <<EOF > ./fish/config.fish
if status is-interactive
    fastfetch
end

set -g fish_greeting
set -x DOTNET_CLI_TELEMETRY_OPTOUT 1
set -gx PATH \$PATH /home/$username/.dotnet/tools
EOF
sudo cp -fr ./fish ~/.config/

echo "Copy Kvantum"
sudo tar -xJf ./Kvantum/Layan.tar.xz -C /usr/share/Kvantum/
sudo tar -xJf ./Kvantum/Layan-solid.tar.xz -C /usr/share/Kvantum/
sudo tar -xJf ./Kvantum/Sweet.tar.xz -C /usr/share/Kvantum/
sudo tar -xJf ./Kvantum/Sweet-Ambar-Blue.tar.xz -C /usr/share/Kvantum/
sudo tar -xJf ./Kvantum/Sweet-Mars.tar.xz -C /usr/share/Kvantum/
sudo tar -xJf ./Kvantum/Sweet-Mars-transparent-toolbar.tar.xz -C /usr/share/Kvantum/
sudo tar -xJf ./Kvantum/Sweet-transparent-toolbar.tar.xz -C /usr/share/Kvantum/

echo "==> Cài đặt DOTNET"
wget -P ~/Downloads https://builds.dotnet.microsoft.com/dotnet/Sdk/8.0.414/dotnet-sdk-8.0.414-linux-x64.tar.gz
sudo mkdir -p /usr/share/dotnet
sudo tar -xzf ~/Downloads/dotnet-sdk-8.0.414-linux-x64.tar.gz -C /usr/share/dotnet/
sudo ln -sf /usr/share/dotnet/dotnet /usr/bin/dotnet

dotnet --info
dotnet tool update -g linux-dev-certs
dotnet linux-dev-certs install
dotnet dev-certs https --trust

git config --global credential.helper store

echo "Hoàn tất cài đặt Ứng dụng!"
