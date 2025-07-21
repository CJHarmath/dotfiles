#!/usr/bin/env bash
# Safe Core Module Installation Script
# Creates proper backups before any changes

set -euo pipefail

CORE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$CORE_DIR")"
CONFIG_DIR="$HOME/.config"
BACKUP_ROOT="$HOME/.dotfiles-backups"

source "$DOTFILES_DIR/scripts/utils.sh"
source "$DOTFILES_DIR/scripts/backup.sh"

# Detect OS
OS=$(uname -s | tr '[:upper:]' '[:lower:]')

echo "Installing Core Module (Safe Mode)..."

# Create backup timestamp
BACKUP_TIMESTAMP=$(date +%Y%m%d-%H%M%S)
BACKUP_DIR="$BACKUP_ROOT/$BACKUP_TIMESTAMP-core-install"

echo "Creating backup at: $BACKUP_DIR"

# List of files that will be modified
FILES_TO_BACKUP=(
    "$HOME/.zshrc"
    "$HOME/.zshenv"
    "$HOME/.gitconfig"
    "$HOME/.tmux.conf"
    "$CONFIG_DIR/nvim"
    "$CONFIG_DIR/wezterm"
    "$CONFIG_DIR/zellij"
    "$CONFIG_DIR/starship.toml"
    "$CONFIG_DIR/bat"
    "$CONFIG_DIR/atuin"
    "$CONFIG_DIR/zsh"
)

# Backup all files that exist
for file in "${FILES_TO_BACKUP[@]}"; do
    if [[ -e "$file" ]] || [[ -L "$file" ]]; then
        backup_file "$file" "$BACKUP_DIR"
    fi
done

# Create backup manifest
create_backup_manifest "$BACKUP_DIR"

echo
echo "Backup complete. You can restore with:"
echo "  $DOTFILES_DIR/scripts/restore.sh $BACKUP_DIR"
echo

# Now proceed with installation
read -p "Continue with installation? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Installation cancelled. Backup preserved at: $BACKUP_DIR"
    exit 0
fi

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
    fi
fi

# Create config directories
echo "Creating configuration directories..."
mkdir -p "$CONFIG_DIR"/{nvim,wezterm,zellij,tmux,bat,atuin,starship,zsh}
mkdir -p "$HOME/.local/"{bin,share,state}

# Enhanced link function that tracks what we're doing
link_config_safe() {
    local src=$1
    local dst=$2
    
    # Record this symlink in our tracking file
    echo "$dst -> $src" >> "$BACKUP_DIR/symlinks.txt"
    
    # Create parent directory if needed
    mkdir -p "$(dirname "$dst")"
    
    # If destination exists and is not a symlink, it should already be backed up
    if [[ -e "$dst" ]] && [[ ! -L "$dst" ]]; then
        echo "Warning: $dst exists but should have been backed up"
        return 1
    fi
    
    # Remove existing symlink
    [[ -L "$dst" ]] && rm "$dst"
    
    # Create new symlink
    ln -sf "$src" "$dst"
    echo "Linked: $src -> $dst"
}

# Link configurations using drop-in approach where possible
echo "Linking configurations..."

# Zsh - use drop-in directory
link_config_safe "$CORE_DIR/shell/zsh/.zshrc" "$HOME/.zshrc"
link_config_safe "$CORE_DIR/shell/zsh/.zshenv" "$HOME/.zshenv"
link_config_safe "$CORE_DIR/shell/zsh/conf.d" "$CONFIG_DIR/zsh/conf.d"

# Other configs
link_config_safe "$CORE_DIR/shell/starship/starship.toml" "$CONFIG_DIR/starship.toml"
link_config_safe "$CORE_DIR/editor/nvim" "$CONFIG_DIR/nvim"
link_config_safe "$CORE_DIR/terminal/wezterm/wezterm.lua" "$CONFIG_DIR/wezterm/wezterm.lua"
link_config_safe "$CORE_DIR/multiplexer/zellij/config.kdl" "$CONFIG_DIR/zellij/config.kdl"
link_config_safe "$CORE_DIR/multiplexer/zellij/layouts.kdl" "$CONFIG_DIR/zellij/layouts.kdl"
link_config_safe "$CORE_DIR/multiplexer/tmux/tmux.conf" "$HOME/.tmux.conf"
link_config_safe "$CORE_DIR/git/.gitconfig" "$HOME/.gitconfig"
link_config_safe "$CORE_DIR/modern-cli/bat/config" "$CONFIG_DIR/bat/config"
link_config_safe "$CORE_DIR/modern-cli/atuin/config.toml" "$CONFIG_DIR/atuin/config.toml"

# Install Zinit (Zsh plugin manager)
if [[ ! -d "$HOME/.local/share/zinit" ]]; then
    echo "Installing Zinit..."
    bash -c "$(curl --fail --show-error --silent --location https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh)"
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

# Create local override files
echo "Creating local override files..."
touch "$HOME/.zshrc.local"
mkdir -p "$CONFIG_DIR/nvim/lua/config"
touch "$CONFIG_DIR/nvim/lua/config/local.lua"
mkdir -p "$CONFIG_DIR/wezterm"
touch "$CONFIG_DIR/wezterm/local.lua"

# Save installation record
cat > "$DOTFILES_DIR/state/core-install-record.json" << EOF
{
  "installed_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "backup_location": "$BACKUP_DIR",
  "symlinks_created": "$BACKUP_DIR/symlinks.txt"
}
EOF

echo
echo "Core module installed successfully!"
echo
echo "Installation record saved. You can uninstall with:"
echo "  $CORE_DIR/uninstall-safe.sh"
echo
echo "Next steps:"
echo "1. Restart your terminal or run: exec zsh"
echo "2. Launch Neovim - plugins will auto-install"
echo "3. Configure local overrides in ~/.zshrc.local if needed"