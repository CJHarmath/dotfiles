#!/usr/bin/env bash
# Core Module Installation Script
# Installs essential terminal tools and configurations

set -euo pipefail

CORE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$CORE_DIR")"
CONFIG_DIR="$HOME/.config"

source "$DOTFILES_DIR/scripts/utils.sh" 2>/dev/null || true

# Detect OS
OS=$(uname -s | tr '[:upper:]' '[:lower:]')

echo "Installing Core Module..."

# Install package managers if needed
if [[ "$OS" == "darwin" ]] && ! command -v brew &> /dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zprofile"
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Install core packages
echo "Installing core packages..."
if [[ "$OS" == "darwin" ]]; then
    # Install from Brewfile if exists
    if [[ -f "$DOTFILES_DIR/Brewfile.core" ]]; then
        brew bundle --file="$DOTFILES_DIR/Brewfile.core"
    else
        # Install essential packages
        brew install \
            zsh \
            neovim \
            wezterm \
            zellij \
            tmux \
            starship \
            bat \
            eza \
            fd \
            ripgrep \
            fzf \
            delta \
            zoxide \
            atuin \
            git \
            gh \
            jq
    fi
elif [[ -f /etc/fedora-release ]]; then
    # Install packages on Fedora
    sudo dnf install -y \
        zsh \
        neovim \
        tmux \
        git \
        gh \
        jq \
        curl \
        wget
    
    # Install Rust tools via cargo
    if ! command -v cargo &> /dev/null; then
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        source "$HOME/.cargo/env"
    fi
    
    cargo install \
        starship \
        bat \
        eza \
        fd-find \
        ripgrep \
        delta \
        zoxide \
        atuin
fi

# Create config directories
echo "Creating configuration directories..."
mkdir -p "$CONFIG_DIR"/{nvim,wezterm,zellij,tmux,bat,atuin,starship}
mkdir -p "$HOME/.local/"{bin,share,state}

# Function to create symlink
link_config() {
    local src=$1
    local dst=$2
    
    # Create parent directory if needed
    mkdir -p "$(dirname "$dst")"
    
    # Backup existing file/directory
    if [[ -e "$dst" ]] && [[ ! -L "$dst" ]]; then
        echo "Backing up existing file: $dst"
        mv "$dst" "$dst.backup.$(date +%s)"
    fi
    
    # Create symlink
    ln -sf "$src" "$dst"
    echo "Linked: $src -> $dst"
}

# Link shell configurations
echo "Linking shell configurations..."
link_config "$CORE_DIR/shell/zsh/.zshrc" "$HOME/.zshrc"
link_config "$CORE_DIR/shell/zsh/.zshenv" "$HOME/.zshenv"
link_config "$CORE_DIR/shell/starship/starship.toml" "$CONFIG_DIR/starship.toml"

# Link zsh config directory
mkdir -p "$CONFIG_DIR/zsh"
link_config "$CORE_DIR/shell/zsh/conf.d" "$CONFIG_DIR/zsh/conf.d"

# Link editor configuration
echo "Linking editor configuration..."
link_config "$CORE_DIR/editor/nvim" "$CONFIG_DIR/nvim"

# Link terminal configuration
echo "Linking terminal configuration..."
mkdir -p "$CONFIG_DIR/wezterm"
link_config "$CORE_DIR/terminal/wezterm/wezterm.lua" "$CONFIG_DIR/wezterm/wezterm.lua"

# Link multiplexer configurations
echo "Linking multiplexer configurations..."
link_config "$CORE_DIR/multiplexer/zellij/config.kdl" "$CONFIG_DIR/zellij/config.kdl"
link_config "$CORE_DIR/multiplexer/zellij/layouts.kdl" "$CONFIG_DIR/zellij/layouts.kdl"
link_config "$CORE_DIR/multiplexer/tmux/tmux.conf" "$HOME/.tmux.conf"

# Link git configuration
echo "Linking git configuration..."
link_config "$CORE_DIR/git/.gitconfig" "$HOME/.gitconfig"

# Link modern CLI tool configurations
echo "Linking modern CLI configurations..."
link_config "$CORE_DIR/modern-cli/bat/config" "$CONFIG_DIR/bat/config"
link_config "$CORE_DIR/modern-cli/atuin/config.toml" "$CONFIG_DIR/atuin/config.toml"

# Install Zinit (Zsh plugin manager)
if [[ ! -d "$HOME/.local/share/zinit" ]]; then
    echo "Installing Zinit..."
    bash -c "$(curl --fail --show-error --silent --location https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh)"
fi

# Install fzf key bindings
if command -v fzf &> /dev/null; then
    echo "Installing fzf key bindings..."
    if [[ "$OS" == "darwin" ]]; then
        "$(brew --prefix)/opt/fzf/install" --key-bindings --completion --no-update-rc --no-bash --no-fish || true
    fi
fi

# Change default shell to zsh if needed
if [[ "$SHELL" != */zsh ]]; then
    echo "Changing default shell to zsh..."
    if [[ "$OS" == "darwin" ]]; then
        # Add zsh to allowed shells if not already there
        if ! grep -q "$(which zsh)" /etc/shells; then
            echo "$(which zsh)" | sudo tee -a /etc/shells
        fi
    fi
    chsh -s "$(which zsh)" || echo "Please manually change your shell to zsh"
fi

# Install Neovim plugins
echo "Installing Neovim plugins..."
nvim --headless "+Lazy! sync" +qa || echo "Neovim plugins will be installed on first launch"

# Create local override files
echo "Creating local override files..."
touch "$HOME/.zshrc.local"
mkdir -p "$CONFIG_DIR/nvim/lua/config"
touch "$CONFIG_DIR/nvim/lua/config/local.lua"
mkdir -p "$CONFIG_DIR/wezterm"
touch "$CONFIG_DIR/wezterm/local.lua"

echo
echo "Core module installed successfully!"
echo
echo "Next steps:"
echo "1. Restart your terminal or run: source ~/.zshrc"
echo "2. Launch Neovim and wait for plugins to install"
echo "3. Configure local overrides in ~/.zshrc.local if needed"