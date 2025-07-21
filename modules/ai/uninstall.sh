#!/usr/bin/env bash
# AI Module Uninstall Script
# Removes AI module configurations and optionally tools

set -euo pipefail

MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$(dirname "$MODULE_DIR")")"
CONFIG_DIR="$HOME/.config"
AI_CONFIG_DIR="$CONFIG_DIR/ai-tools"

source "$DOTFILES_DIR/scripts/utils.sh"

echo "Uninstalling AI Module..."

# Remove configurations
echo "Removing configurations..."
safe_unlink "$CONFIG_DIR/shell_gpt/.sgptrc"
safe_unlink "$HOME/.aider.conf.yml"

# Remove AI config directory
if [[ -d "$AI_CONFIG_DIR" ]]; then
    if confirm "Remove AI configuration directory ($AI_CONFIG_DIR)?"; then
        rm -rf "$AI_CONFIG_DIR"
        log SUCCESS "Removed AI config directory"
    fi
fi

# Remove shell integrations from zshrc
ZSHRC="$HOME/.zshrc"
if [[ -f "$ZSHRC" ]]; then
    echo "Removing shell integrations from zshrc..."
    
    # Create backup
    cp "$ZSHRC" "$ZSHRC.backup.$(date +%s)"
    
    # Remove AI functions block
    sed -i.tmp '/# AI Module Functions/,/^$/d' "$ZSHRC" 2>/dev/null || true
    
    # Remove AI environment setup
    sed -i.tmp '/# AI Environment Setup/,/^$/d' "$ZSHRC" 2>/dev/null || true
    
    # Clean up temporary file
    rm -f "$ZSHRC.tmp"
    
    log SUCCESS "Removed shell integrations"
fi

# Ask about removing tools
echo
if confirm "Remove installed AI tools?"; then
    echo "Removing AI tools..."
    
    # Remove shell-gpt
    if command_exists sgpt; then
        if command_exists pip3; then
            pip3 uninstall shell-gpt -y 2>/dev/null || true
        elif command_exists pipx; then
            pipx uninstall shell-gpt 2>/dev/null || true
        fi
        log SUCCESS "Removed shell-gpt"
    fi
    
    # Remove aider
    if command_exists aider; then
        if command_exists pip3; then
            pip3 uninstall aider-chat -y 2>/dev/null || true
        elif command_exists pipx; then
            pipx uninstall aider-chat 2>/dev/null || true
        fi
        log SUCCESS "Removed aider"
    fi
    
    # Remove GitHub Copilot CLI extension
    if command_exists gh && gh extension list | grep -q copilot; then
        gh extension remove github/gh-copilot 2>/dev/null || true
        log SUCCESS "Removed gh-copilot extension"
    fi
    
    # Remove fabric (if installed via go)
    if command_exists fabric && [[ -f "$HOME/go/bin/fabric" ]]; then
        rm -f "$HOME/go/bin/fabric"
        log SUCCESS "Removed fabric"
    fi
    
    # Note about Ollama
    if command_exists ollama; then
        echo
        log INFO "Ollama is still installed. To remove it:"
        if [[ "$(uname -s)" == "Darwin" ]]; then
            echo "  - If installed via Homebrew: brew uninstall ollama"
            echo "  - If installed via installer: Remove from Applications"
        else
            echo "  - Remove ollama binary from your PATH"
            echo "  - Remove ~/.ollama directory"
        fi
    fi
    
    log SUCCESS "AI tools removal complete"
else
    log INFO "AI tools left installed"
fi

# Remove cache directories
if confirm "Remove AI tool caches?"; then
    rm -rf ~/.cache/shell_gpt 2>/dev/null || true
    rm -rf ~/.cache/aider 2>/dev/null || true
    log SUCCESS "Removed AI caches"
fi

echo
echo "AI module uninstalled successfully!"
echo
echo "You may need to restart your shell for changes to take effect."