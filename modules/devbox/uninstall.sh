#!/usr/bin/env bash
# Devbox Module Uninstall Script
# Removes devbox module configurations and optionally tools

set -euo pipefail

MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$(dirname "$MODULE_DIR")")"
CONFIG_DIR="$HOME/.config"

source "$DOTFILES_DIR/scripts/utils.sh"

echo "Uninstalling Devbox Module..."

# Remove configurations
echo "Removing configurations..."
safe_unlink "$CONFIG_DIR/direnv/direnvrc"
safe_unlink "$CONFIG_DIR/mise/config.toml"

# Remove shell integrations from zshrc
ZSHRC="$HOME/.zshrc"
if [[ -f "$ZSHRC" ]]; then
    echo "Removing shell integrations from zshrc..."
    
    # Create backup
    cp "$ZSHRC" "$ZSHRC.backup.$(date +%s)"
    
    # Remove direnv hook
    sed -i.tmp '/# Devbox module integrations/d' "$ZSHRC" 2>/dev/null || true
    sed -i.tmp '/eval.*direnv hook/d' "$ZSHRC" 2>/dev/null || true
    sed -i.tmp '/eval.*mise activate/d' "$ZSHRC" 2>/dev/null || true
    
    # Clean up temporary file
    rm -f "$ZSHRC.tmp"
    
    log SUCCESS "Removed shell integrations"
fi

# Remove example project
EXAMPLE_DIR="$HOME/.dotfiles-examples/devbox-example"
if [[ -d "$EXAMPLE_DIR" ]]; then
    if confirm "Remove example project at $EXAMPLE_DIR?"; then
        rm -rf "$EXAMPLE_DIR"
        log SUCCESS "Removed example project"
    fi
fi

# Ask about removing tools
echo
if confirm "Remove installed tools (devbox, direnv, just, mise)?"; then
    OS=$(detect_os)
    
    if [[ "$OS" == "macos" ]] && command_exists brew; then
        echo "Removing tools via Homebrew..."
        brew uninstall --ignore-dependencies direnv just mise-en-place 2>/dev/null || true
    elif command_exists cargo; then
        echo "Removing Rust-installed tools..."
        cargo uninstall just 2>/dev/null || true
    fi
    
    # Remove devbox (manual removal)
    if command_exists devbox; then
        echo "Note: devbox should be removed manually:"
        echo "  - Remove devbox binary from your PATH"
        echo "  - Remove ~/.local/share/devbox if it exists"
    fi
    
    # Remove mise (manual removal)
    if command_exists mise && [[ -f ~/.local/bin/mise ]]; then
        rm -f ~/.local/bin/mise
        log SUCCESS "Removed mise"
    fi
    
    log SUCCESS "Tools removal complete"
else
    log INFO "Tools left installed"
fi

echo
echo "Devbox module uninstalled successfully!"
echo
echo "You may need to restart your shell for changes to take effect."