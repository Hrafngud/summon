#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[*]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[!]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Detect package manager
if command -v apt >/dev/null 2>&1; then
    PM="apt"
    UPDATE_CMD="sudo apt update"
    INSTALL_CMD="sudo apt install"
elif command -v pacman >/dev/null 2>&1; then
    PM="pacman"
    UPDATE_CMD="sudo pacman -Syu --noconfirm"
    INSTALL_CMD="sudo pacman -S --noconfirm"
else
    log_error "Unsupported package manager. Only apt and pacman are supported."
    exit 1
fi

log_info "Using package manager: $PM"

# Update system
log_info "Updating system..."
$UPDATE_CMD

# Install core packages
log_info "Installing core packages..."
if [ "$PM" = "apt" ]; then
    $INSTALL_CMD curl git build-essential zsh btop nethogs fzf
elif [ "$PM" = "pacman" ]; then
    $INSTALL_CMD curl git base-devel zsh btop nethogs fzf exa
fi

# Install exa (different approach for apt)
log_info "Installing exa..."
if [ "$PM" = "apt" ]; then
    # For apt, we'll install via cargo or use eza as alternative
    if command -v cargo >/dev/null 2>&1; then
        cargo install exa
    else
        log_warn "exa not available via apt. Installing eza as modern alternative..."
        # Install eza (modern replacement for exa)
        wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
        echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
        sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
        sudo apt update
        sudo apt install -y eza
        EXA_CMD="eza"
    fi
elif [ "$PM" = "pacman" ]; then
    # exa is already installed via pacman above
    EXA_CMD="exa"
fi

# Set exa command if not set
if [ -z "$EXA_CMD" ]; then
    if command -v exa >/dev/null 2>&1; then
        EXA_CMD="exa"
    elif command -v eza >/dev/null 2>&1; then
        EXA_CMD="eza"
    else
        log_warn "Neither exa nor eza found. Using ls instead."
        EXA_CMD="ls"
    fi
fi

# NVM + Node + PM2
log_info "Installing NVM..."
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

log_info "Installing Node.js LTS..."
nvm install --lts

log_info "Installing PM2..."
npm install -g pm2

# Python
log_info "Installing Python3 + pip..."
if [ "$PM" = "apt" ]; then
    $INSTALL_CMD python3 python3-pip
elif [ "$PM" = "pacman" ]; then
    $INSTALL_CMD python python-pip
fi

# Go
GO_VERSION="1.22.4"
log_info "Installing Go ${GO_VERSION}..."
curl -LO https://golang.org/dl/go${GO_VERSION}.linux-amd64.tar.gz
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz
rm go${GO_VERSION}.linux-amd64.tar.gz
export PATH=$PATH:/usr/local/go/bin

# Add Go to PATH permanently
if ! grep -q "/usr/local/go/bin" ~/.profile; then
    echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.profile
fi

# Zoxide
log_info "Installing zoxide..."
curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash

# Zsh + p10k + aliases
log_info "Setting Zsh as default shell..."
chsh -s "$(which zsh)"

log_info "Installing Oh My Zsh..."
if [ ! -d "${HOME}/.oh-my-zsh" ]; then
    RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

log_info "Installing Powerlevel10k theme..."
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
      ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
fi

# Update .zshrc theme
sed -i 's|^ZSH_THEME=.*|ZSH_THEME="powerlevel10k/powerlevel10k"|' ~/.zshrc

log_info "Adding aliases + zoxide init to .zshrc..."
# Check if aliases already exist to avoid duplicates
if ! grep -q "zoxide init zsh" ~/.zshrc; then
    {
        echo ''
        echo '# Custom aliases and tools'
        echo 'eval "$(zoxide init zsh)"'
        echo 'alias z="zoxide cd"'
        echo 'alias zi="zoxide query -l | fzf | xargs -r zoxide cd"'
        if [ "$EXA_CMD" = "ls" ]; then
            echo 'alias ll="ls -lah"'
        else
            echo "alias ll=\"$EXA_CMD -lah --git\""
        fi
    } >> ~/.zshrc
fi

# Summary
log_info "Setup complete! Installed versions:"
echo "Go: $(go version 2>/dev/null || echo 'Not in current PATH - restart shell')"
echo "Node: $(node -v 2>/dev/null || echo 'Not in current PATH - restart shell')"
echo "NPM: $(npm -v 2>/dev/null || echo 'Not in current PATH - restart shell')"
echo "Python: $(python3 --version 2>/dev/null || echo 'Not found')"
echo "Pip: $(pip3 --version 2>/dev/null || echo 'Not found')"
echo "PM2: $(pm2 -v 2>/dev/null || echo 'Not in current PATH - restart shell')"
echo "Zsh: $(zsh --version 2>/dev/null || echo 'Not found')"
echo "btop: $(btop --version 2>/dev/null || echo 'Installed')"
echo "fzf: $(fzf --version 2>/dev/null || echo 'Not found')"
echo "exa/eza: $($EXA_CMD --version 2>/dev/null || echo "Using: $EXA_CMD")"

log_info "Please restart your shell or run 'source ~/.zshrc' to apply changes."
log_warn "You may need to run 'p10k configure' to set up Powerlevel10k theme."
