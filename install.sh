#!/usr/bin/env bash

set -e

echo "=== Neovim Config Installer ==="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Detect package manager
detect_package_manager() {
    if command -v pacman &> /dev/null; then
        echo "pacman"
    elif command -v apt &> /dev/null; then
        echo "apt"
    elif command -v dnf &> /dev/null; then
        echo "dnf"
    else
        echo "unknown"
    fi
}

PKG_MANAGER=$(detect_package_manager)

echo -e "${GREEN}Detected package manager: $PKG_MANAGER${NC}"
echo ""

# Check if nvim is installed
if ! command -v nvim &> /dev/null; then
    echo -e "${RED}Neovim not found!${NC}"
    echo "Install it first, then run this script again."
    exit 1
fi

echo -e "${GREEN}✓ Neovim found${NC}"

# Backup existing config
if [ -d "$HOME/.config/nvim" ]; then
    BACKUP_DIR="$HOME/.config/nvim.backup.$(date +%Y%m%d_%H%M%S)"
    echo -e "${YELLOW}Backing up existing config to $BACKUP_DIR${NC}"
    mv "$HOME/.config/nvim" "$BACKUP_DIR"
fi

# Create config directory
mkdir -p "$HOME/.config/nvim"

# Copy init.lua (assumes it's in the same directory as the script)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/init.lua" ]; then
    cp "$SCRIPT_DIR/init.lua" "$HOME/.config/nvim/init.lua"
    echo -e "${GREEN}✓ Copied init.lua${NC}"
else
    echo -e "${RED}Error: init.lua not found in $SCRIPT_DIR${NC}"
    exit 1
fi

# Install dependencies based on package manager
echo ""
echo "=== Installing dependencies ==="
echo ""

install_arch_deps() {
    echo "Installing packages..."
    sudo pacman -S --needed base-devel git ripgrep fd lazygit \
        lua-language-server stylua luacheck \
        rust-analyzer \
        python-pyright python-ruff \
        clang \
        jdk-openjdk \
        nodejs npm
    
    # Formatters/linters via npm
    sudo npm install -g typescript typescript-language-server eslint
}

install_debian_deps() {
    echo "Installing packages..."
    sudo apt update
    sudo apt install -y build-essential git ripgrep fd-find lazygit \
        clang clangd \
        python3-pip \
        default-jdk \
        nodejs npm
    
    # Language servers and tools via npm/pip
    sudo npm install -g lua-language-server typescript typescript-language-server eslint
    pip3 install --user pyright ruff stylua
}

install_fedora_deps() {
    echo "Installing packages..."
    sudo dnf install -y @development-tools git ripgrep fd-find lazygit \
        clang clang-tools-extra \
        python3-pip \
        java-latest-openjdk-devel \
        nodejs npm
    
    # Language servers and tools
    sudo npm install -g lua-language-server typescript typescript-language-server eslint
    pip3 install --user pyright ruff
}

case $PKG_MANAGER in
    pacman)
        install_arch_deps
        echo -e "${GREEN}✓ Dependencies installed${NC}"
        ;;
    apt)
        install_debian_deps
        echo -e "${GREEN}✓ Dependencies installed${NC}"
        ;;
    dnf)
        install_fedora_deps
        echo -e "${GREEN}✓ Dependencies installed${NC}"
        ;;
    *)
        echo -e "${RED}Unknown package manager. Install dependencies manually:${NC}"
        echo "- git, gcc, make"
        echo "- ripgrep, fd, lazygit"
        echo "- Language servers: lua-language-server, nixd, rust-analyzer, pyright, clangd, etc."
        echo "- Formatters: stylua, nixfmt"
        echo "- Linters: luacheck, ruff, cppcheck, eslint"
        ;;
esac

echo ""
echo "=== Setup complete! ==="
echo ""
echo "Next steps:"
echo "1. Open Neovim: nvim"
echo "2. Lazy.nvim will auto-install plugins (wait for it to finish)"
echo "3. Run :Mason to check LSP server status"
echo "4. Restart Neovim"
echo ""
echo -e "${YELLOW}Note: First launch will have some errors - this is normal!${NC}"
echo -e "${YELLOW}Everything will work after plugins finish installing.${NC}"
echo ""
echo "Keybindings:"
echo "  <Space>ff - Find files"
echo "  <Space>fg - Live grep"
echo "  <Space>e  - File explorer"
echo "  <Space>o  - Oil (directory editor)"
echo "  <Space>lg - Lazygit"
echo "  <C-\\>    - Toggle terminal"
echo ""
echo "Happy vimming! 🚀"
