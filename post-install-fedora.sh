#!/bin/bash

set -e

# Atualizando sistema
echo "==> Atualizando o sistema..."
sudo dnf update -y
flatpak update -y

echo "==> Configurando repositórios..."

# VS Code
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
echo -e '[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\nautorefresh=1\ntype=rpm-md\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc' | sudo tee /etc/yum.repos.d/vscode.repo > /dev/null

# Docker
sudo dnf -y install dnf-plugins-core
sudo dnf-3 config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo

echo "==> Instalando pacotes RPM..."
sudo dnf check-update
sudo dnf install -y gnome-shell-extension-gsconnect gnome-tweaks code zsh

# Baixar e instalar pacotes RPM manualmente
wget https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm
wget https://downloads.1password.com/linux/rpm/stable/x86_64/1password-latest.rpm
wget https://desktop.docker.com/linux/main/amd64/docker-desktop-x86_64.rpm
sudo dnf install -y ./google-chrome-stable_current_x86_64.rpm ./1password-latest.rpm ./docker-desktop-x86_64.rpm
rm -f ./google-chrome-stable_current_x86_64.rpm ./1password-latest.rpm ./docker-desktop-x86_64.rpm

echo "==> Instalando apps Flatpak..."
flatpak install -y flathub com.discordapp.Discord
flatpak install -y flathub io.missioncenter.MissionCenter
flatpak install -y flathub com.spotify.Client
flatpak install -y flathub md.obsidian.Obsidian
flatpak install -y flathub io.github.flattool.Warehouse
flatpak install -y flathub org.gnome.Extensions
flatpak install -y flathub com.mattjakeman.ExtensionManager
flatpak install -y flathub com.surfshark.Surfshark
flatpak install -y flathub org.gnome.Mahjongg

echo "==> Instalando JetBrains Toolbox (AppImage)..."
TOOLBOX_VERSION=jetbrains-toolbox-2.6.2.41321
wget https://download-cdn.jetbrains.com/toolbox/$TOOLBOX_VERSION.tar.gz
tar -xf $TOOLBOX_VERSION.tar.gz
mkdir -p ~/Apps
mv $TOOLBOX_VERSION/jetbrains-toolbox ~/Apps
rm -rf $TOOLBOX_VERSION*

echo "==> Configurando dotfiles..."

# Git config
rm -f ~/.gitconfig
cat <<EOF > ~/.gitconfig
[user]
    name = Maycon Jesus
    email = contato@mayconjesus.dev
    signingkey = ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG2o3ngJET2MzJZRRKI7PQk32f1L6xf0hrgRzrjQLmG9
[gpg]
    format = ssh
[gpg "ssh"]
    program = /opt/1Password/op-ssh-sign
[commit]
    gpgsign = true
EOF

# SSH config
mkdir -p ~/.ssh
rm -f ~/.ssh/config
cat <<EOF > ~/.ssh/config
Host *
    IdentityAgent ~/.1password/agent.sock
EOF

# 1Password config
mkdir -p ~/.config/1Password/ssh/
cat <<EOF > ~/.config/1Password/ssh/agent.toml
[[ssh-keys]]
vault = "DEV"
EOF

echo "==> Instalando ZSH e Starship..."
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
curl -sS https://starship.rs/install.sh | sh
starship preset jetpack -o ~/.config/starship.toml

echo "==> Instalando fontes Nerd Fonts..."
mkdir -p ~/.local/share/fonts

for font in Hack FiraCode Ubuntu UbuntuMono UbuntuSans JetBrainsMono; do
    wget "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/${font}.zip"
    unzip "${font}.zip" -d "${font}"
    mv "${font}"/*.ttf ~/.local/share/fonts
    rm -rf "${font}"*
done

fc-cache

# Golang
echo "==> Instalando Golang..."
wget https://go.dev/dl/go1.24.3.linux-amd64.tar.gz
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf go1.24.3.linux-amd64.tar.gz
rm go1.24.3.linux-amd64*

# settings zshrc
#golang path
echo "==> Configurando PATH Golang..."
if ! grep -q "export PATH=\$PATH:/usr/local/go/bin" "$HOME/.profile"; then
    echo "export PATH=\$PATH:/usr/local/go/bin" >> ~/.profile
fi
if test -f ~/.zshrc; then
    if ! grep -q "export PATH=\$PATH:/usr/local/go/bin" "$HOME/.zshrc"; then
        echo "export PATH=\$PATH:/usr/local/go/bin" >> ~/.zshrc
    fi
fi

# zsh aliases
echo "==> Configurando ZSH Aliases..."
echo "alias t=\"nohup ptyxis --working-directory . --tab >/dev/null 2>&1 &\"" >> ~/.zshrc

# starship
echo "==> Configurando Tema ZSH Starship..."
echo "eval \"$(starship init zsh)\"" >> ~/.zshrc

# Customizaćões GNOME
echo "==> Instalando tema Orchis..."
wget https://github.com/vinceliuice/Orchis-theme/archive/refs/heads/master.zip -O orchis-theme.zip
unzip orchis-theme.zip -d orchis-theme
./orchis-theme/Orchis-theme-master/install.sh -c dark -s standard -l -f --tweaks "compact black"
rm -rf orchis-theme*
sudo flatpak override --filesystem=xdg-config/gtk-3.0
sudo flatpak override --filesystem=xdg-config/gtk-4.0

echo "==> Instalando tema de ícones Tela..."
wget https://github.com/vinceliuice/Tela-icon-theme/archive/refs/heads/master.zip -O tela-icon.zip
unzip tela-icon.zip -d tela-icon
./tela-icon/Tela-icon-theme-master/install.sh blue
rm -rf tela-icon*

echo "==> Baixando wallpapers..."
WALLPAPER_FOLDER=~/Pictures
wget https://github.com/biglinux/extra-biglinux-wallpapers/archive/refs/heads/main.zip -O $WALLPAPER_FOLDER/wallpapers.zip
unzip $WALLPAPER_FOLDER/wallpapers.zip -d $WALLPAPER_FOLDER/temp-wallpapers
mv $WALLPAPER_FOLDER/temp-wallpapers/extra-biglinux-wallpapers-main/usr/share/wallpapers $WALLPAPER_FOLDER/wallpapers
rm -rf $WALLPAPER_FOLDER/wallpapers.zip $WALLPAPER_FOLDER/temp-wallpapers