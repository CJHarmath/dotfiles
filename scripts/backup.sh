#!/usr/bin/env bash
# Backup helper functions for dotfiles

set -euo pipefail

# Create a timestamped backup of a file or directory
backup_file() {
    local file=$1
    local backup_dir=${2:-"$HOME/.dotfiles-backups"}
    local timestamp=$(date +%Y%m%d-%H%M%S)
    
    if [[ ! -e "$file" ]]; then
        return 0  # Nothing to backup
    fi
    
    # Create backup directory if it doesn't exist
    mkdir -p "$backup_dir"
    
    # Get the relative path from home
    local relative_path="${file#$HOME/}"
    local backup_path="$backup_dir/$timestamp/$relative_path"
    
    # Create parent directory in backup
    mkdir -p "$(dirname "$backup_path")"
    
    # Copy the file/directory
    if [[ -L "$file" ]]; then
        # It's a symlink - save where it points to
        echo "$(readlink "$file")" > "$backup_path.symlink"
        echo "Backed up symlink: $file -> $backup_path.symlink"
    elif [[ -d "$file" ]]; then
        cp -R "$file" "$backup_path"
        echo "Backed up directory: $file -> $backup_path"
    else
        cp "$file" "$backup_path"
        echo "Backed up file: $file -> $backup_path"
    fi
    
    # Return the backup location
    echo "$backup_dir/$timestamp"
}

# Restore a file from backup
restore_file() {
    local original_path=$1
    local backup_root=${2:-"$HOME/.dotfiles-backups"}
    
    # Find the most recent backup
    local relative_path="${original_path#$HOME/}"
    local latest_backup=""
    
    for backup in "$backup_root"/*/"$relative_path"*; do
        if [[ -e "$backup" ]]; then
            latest_backup="$backup"
        fi
    done
    
    if [[ -z "$latest_backup" ]]; then
        echo "No backup found for: $original_path"
        return 1
    fi
    
    # Remove current file/directory/symlink
    if [[ -e "$original_path" ]] || [[ -L "$original_path" ]]; then
        rm -rf "$original_path"
    fi
    
    # Restore from backup
    if [[ -f "$latest_backup.symlink" ]]; then
        # Restore symlink
        local target=$(cat "$latest_backup.symlink")
        ln -s "$target" "$original_path"
        echo "Restored symlink: $original_path -> $target"
    elif [[ -d "$latest_backup" ]]; then
        cp -R "$latest_backup" "$original_path"
        echo "Restored directory: $original_path from $latest_backup"
    else
        cp "$latest_backup" "$original_path"
        echo "Restored file: $original_path from $latest_backup"
    fi
}

# Create a backup manifest
create_backup_manifest() {
    local backup_dir=$1
    local manifest_file="$backup_dir/MANIFEST.txt"
    
    cat > "$manifest_file" << EOF
Dotfiles Backup Manifest
Created: $(date)
Host: $(hostname)
User: $USER

Files backed up:
EOF
    
    find "$backup_dir" -type f ! -name "MANIFEST.txt" | while read -r file; do
        echo "  ${file#$backup_dir/}" >> "$manifest_file"
    done
}

# Export functions for use in other scripts
export -f backup_file
export -f restore_file
export -f create_backup_manifest