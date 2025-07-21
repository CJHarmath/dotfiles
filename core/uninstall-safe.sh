#!/usr/bin/env bash
# Safe Core Module Uninstall Script
# Restores from backups when uninstalling

set -euo pipefail

CORE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$CORE_DIR")"
CONFIG_DIR="$HOME/.config"

source "$DOTFILES_DIR/scripts/utils.sh"
source "$DOTFILES_DIR/scripts/backup.sh"

echo "Uninstalling Core Module (Safe Mode)..."

# Check for installation record
INSTALL_RECORD="$DOTFILES_DIR/state/core-install-record.json"
if [[ -f "$INSTALL_RECORD" ]]; then
    BACKUP_LOCATION=$(jq -r '.backup_location' "$INSTALL_RECORD" 2>/dev/null || echo "")
    echo "Found installation record. Backup location: $BACKUP_LOCATION"
else
    echo "No installation record found."
    # Try to find the most recent backup
    BACKUP_LOCATION=$(find "$HOME/.dotfiles-backups" -name "*-core-install" -type d | sort | tail -1)
    if [[ -n "$BACKUP_LOCATION" ]]; then
        echo "Found backup at: $BACKUP_LOCATION"
    else
        echo "No backups found. Proceeding with standard uninstall."
    fi
fi

# List of symlinks to remove
SYMLINKS_TO_REMOVE=(
    "$HOME/.zshrc"
    "$HOME/.zshenv"
    "$HOME/.gitconfig"
    "$HOME/.tmux.conf"
    "$CONFIG_DIR/nvim"
    "$CONFIG_DIR/wezterm/wezterm.lua"
    "$CONFIG_DIR/zellij/config.kdl"
    "$CONFIG_DIR/zellij/layouts.kdl"
    "$CONFIG_DIR/starship.toml"
    "$CONFIG_DIR/bat/config"
    "$CONFIG_DIR/atuin/config.toml"
    "$CONFIG_DIR/zsh/conf.d"
)

# Remove symlinks
echo "Removing symlinks..."
for link in "${SYMLINKS_TO_REMOVE[@]}"; do
    if [[ -L "$link" ]]; then
        rm "$link"
        echo "Removed symlink: $link"
    fi
done

# Restore from backup if available
if [[ -n "$BACKUP_LOCATION" ]] && [[ -d "$BACKUP_LOCATION" ]]; then
    echo
    read -p "Restore from backup at $BACKUP_LOCATION? (Y/n): " -n 1 -r
    echo
    
    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        echo "Restoring from backup..."
        
        # Read the list of backed up files from the manifest
        if [[ -f "$BACKUP_LOCATION/MANIFEST.txt" ]]; then
            # Extract file paths from manifest
            grep -E "^  " "$BACKUP_LOCATION/MANIFEST.txt" | while read -r line; do
                local relative_path="${line#  }"  # Remove leading spaces
                local timestamp="${relative_path%%/*}"  # Get timestamp part
                local file_path="${relative_path#*/}"  # Get path after timestamp
                
                # Skip manifest and symlink info files
                if [[ "$file_path" == "MANIFEST.txt" ]] || [[ "$file_path" == *.symlink ]]; then
                    continue
                fi
                
                local original_path="$HOME/$file_path"
                local backup_path="$BACKUP_LOCATION/$timestamp/$file_path"
                
                # Check if this was a symlink
                if [[ -f "$backup_path.symlink" ]]; then
                    # This was originally a symlink, skip restoration
                    echo "Skipping symlink: $original_path"
                elif [[ -e "$backup_path" ]]; then
                    # Restore the file/directory
                    mkdir -p "$(dirname "$original_path")"
                    if [[ -d "$backup_path" ]]; then
                        cp -R "$backup_path" "$original_path"
                        echo "Restored directory: $original_path"
                    else
                        cp "$backup_path" "$original_path"
                        echo "Restored file: $original_path"
                    fi
                fi
            done
        else
            echo "No manifest found, attempting manual restore..."
            # Fallback to searching for files
            find "$BACKUP_LOCATION" -type f ! -name "*.symlink" ! -name "MANIFEST.txt" ! -name "symlinks.txt" | while read -r backup_file; do
                # Calculate original path
                local relative="${backup_file#$BACKUP_LOCATION/}"
                local timestamp="${relative%%/*}"
                local file_path="${relative#*/}"
                local original_path="$HOME/$file_path"
                
                if [[ -e "$backup_file" ]]; then
                    mkdir -p "$(dirname "$original_path")"
                    cp "$backup_file" "$original_path"
                    echo "Restored: $original_path"
                fi
            done
        fi
        
        echo "Restoration complete!"
    fi
fi

# Remove installation record
if [[ -f "$INSTALL_RECORD" ]]; then
    rm "$INSTALL_RECORD"
    echo "Removed installation record"
fi

# Ask about removing packages
echo
read -p "Remove installed packages? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Package removal must be done manually to avoid removing system dependencies"
    echo "To remove packages on macOS: brew uninstall <package>"
    echo "To remove packages on Fedora: sudo dnf remove <package>"
fi

echo
echo "Core module uninstalled successfully!"
echo
if [[ -n "$BACKUP_LOCATION" ]]; then
    echo "Your backup is preserved at: $BACKUP_LOCATION"
    echo "You can manually restore files from there if needed."
fi