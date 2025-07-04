#!/bin/bash
set -e

# Detect package manager
if command -v apt >/dev/null 2>&1; then
    PM="apt"
    UPDATE_CMD="sudo apt update -y && sudo apt upgrade -y"
    INSTALL_CMD="sudo apt install -y"
elif command -v pacman >/dev/null 2>&1; then
    PM="pacman"
    UPDATE_CMD="sudo pacman -Syu --noconfirm"
    INSTALL_CMD="sudo pacman -S --noconfirm"
else
    echo "Unsupported package manager. Only apt and pacman are supported."
    exit 1
fi

echo "[*] Using package manager: $PM"
echo "[*] Updating system..."
$UPDATE_CMD

# Essentials + tools
echo "[*] Installing core packages..."
if [ "$PM" = "apt" ]; then
    $INSTALL_CMD curl git build-essential zsh btop nethogs fzf exa
elif [ "$PM" = "pacman" ]; then
    $INSTALL_CMD curl git base-devel zsh btop nethogs fzf exa
fi

# NVM + Node + PM2
echo "[*] Installing NVM..."
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

echo "[*] Installing Node.js LTS..."
nvm install --lts

echo "[*] Installing PM2..."
npm install -g pm2

# Python
echo "[*] Installing Python3 + pip..."
if [ "$PM" = "apt" ]; then
    $INSTALL_CMD python3 python3-pip
elif [ "$PM" = "pacman" ]; then
    $INSTALL_CMD python python-pip
fi

# Go
GO_VERSION="1.22.4"
echo "[*] Installing Go ${GO_VERSION}..."
curl -LO https://golang.org/dl/go${GO_VERSION}.linux-amd64.tar.gz
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz
rm go${GO_VERSION}.linux-amd64.tar.gz
export PATH=$PATH:/usr/local/go/bin
if ! grep -q "/usr/local/go/bin" ~/.profile; then
    echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.profile
fi

# Zoxide
echo "[*] Installing zoxide..."
curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash

# Zsh + p10k + aliases
echo "[*] Setting Zsh as default shell..."
chsh -s "$(which zsh)"

echo "[*] Installing Oh My Zsh..."
if [ ! -d "${HOME}/.oh-my-zsh" ]; then
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

echo "[*] Installing Powerlevel10k theme..."
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
  ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

sed -i 's|^ZSH_THEME=.*|ZSH_THEME="powerlevel10k/powerlevel10k"|' ~/.zshrc

echo "[*] Adding aliases + zoxide init to .zshrc..."
{
  echo 'eval "$(zoxide init zsh)"'
  echo 'alias z="zoxide cd"'
  echo 'alias zi="zoxide query -l | fzf | xargs -r zoxide cd"'
  echo 'alias ll="exa -lah --git"'
} >> ~/.zshrc

# Summary
echo "[*] Setup complete! Versions:"
go version
node -v
npm -v
python3 --version
pip3 --version
pm2 -v
zsh --version
btop --version || echo "btop installed"
fzf --version
exa --version
