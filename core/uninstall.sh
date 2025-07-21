#!/usr/bin/env bash
# Core Module Uninstall Script
# Removes core module symlinks and optionally packages

set -euo pipefail

CORE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$CORE_DIR")"
CONFIG_DIR="$HOME/.config"

echo "Uninstalling Core Module..."

# Function to remove symlink
unlink_config() {
    local link=$1
    
    if [[ -L "$link" ]]; then
        rm "$link"
        echo "Removed symlink: $link"
        
        # Restore backup if exists
        if [[ -f "$link.backup."* ]]; then
            local backup=$(ls -t "$link.backup."* | head -1)
            mv "$backup" "$link"
            echo "Restored backup: $backup -> $link"
        fi
    fi
}

# Remove shell configurations
echo "Removing shell configurations..."
unlink_config "$HOME/.zshrc"
unlink_config "$HOME/.zshenv"
unlink_config "$CONFIG_DIR/starship.toml"

# Remove editor configuration
echo "Removing editor configuration..."
unlink_config "$CONFIG_DIR/nvim"

# Remove terminal configuration
echo "Removing terminal configuration..."
unlink_config "$CONFIG_DIR/wezterm/wezterm.lua"

# Remove multiplexer configurations
echo "Removing multiplexer configurations..."
unlink_config "$CONFIG_DIR/zellij/config.kdl"
unlink_config "$CONFIG_DIR/zellij/layouts.kdl"
unlink_config "$HOME/.tmux.conf"

# Remove git configuration
echo "Removing git configuration..."
unlink_config "$HOME/.gitconfig"

# Remove modern CLI configurations
echo "Removing modern CLI configurations..."
unlink_config "$CONFIG_DIR/bat/config"
unlink_config "$CONFIG_DIR/atuin/config.toml"

# Ask about removing packages
read -p "Remove installed packages? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Package removal must be done manually to avoid removing system dependencies"
    echo "To remove packages on macOS: brew uninstall <package>"
    echo "To remove packages on Fedora: sudo dnf remove <package>"
fi

echo
echo "Core module uninstalled successfully!"