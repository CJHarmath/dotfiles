#!/usr/bin/env bash
# Modular Dotfiles Management System
# A simple, reversible way to manage your terminal setup

set -euo pipefail

# Configuration
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STATE_DIR="$DOTFILES_DIR/state"
MANIFEST_FILE="$STATE_DIR/manifest.json"
SYMLINKS_FILE="$STATE_DIR/symlinks.json"
BACKUP_DIR="$STATE_DIR/backups"
LOG_DIR="$STATE_DIR/logs"
LOG_FILE="$LOG_DIR/dotfiles-$(date +%Y%m%d-%H%M%S).log"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

# Logging functions
log() {
    local level=$1
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
    
    case $level in
        ERROR) echo -e "${RED}[ERROR]${NC} $message" >&2 ;;
        WARN)  echo -e "${YELLOW}[WARN]${NC} $message" ;;
        INFO)  echo -e "${BLUE}[INFO]${NC} $message" ;;
        SUCCESS) echo -e "${GREEN}[✓]${NC} $message" ;;
        *) echo "$message" ;;
    esac
}

# Helper functions
ensure_directories() {
    mkdir -p "$STATE_DIR" "$BACKUP_DIR" "$LOG_DIR"
}

init_manifest() {
    if [[ ! -f "$MANIFEST_FILE" ]]; then
        log INFO "Initializing manifest file"
        cat > "$MANIFEST_FILE" <<EOF
{
  "version": "1.0.0",
  "last_updated": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "system": {
    "os": "$(uname -s | tr '[:upper:]' '[:lower:]')",
    "arch": "$(uname -m)",
    "dotfiles_path": "$DOTFILES_DIR"
  },
  "installed_modules": {},
  "tools": {},
  "backups": []
}
EOF
    fi
}

init_symlinks() {
    if [[ ! -f "$SYMLINKS_FILE" ]]; then
        log INFO "Initializing symlinks file"
        cat > "$SYMLINKS_FILE" <<EOF
{
  "version": "1.0.0",
  "symlinks": []
}
EOF
    fi
}

# JSON manipulation helpers (using jq)
json_get() {
    jq -r "$1" "$MANIFEST_FILE" 2>/dev/null || echo ""
}

json_set() {
    local key=$1
    local value=$2
    local temp=$(mktemp)
    jq "$key = $value" "$MANIFEST_FILE" > "$temp" && mv "$temp" "$MANIFEST_FILE"
}

# Module discovery
discover_modules() {
    local module_type=${1:-all}
    
    if [[ "$module_type" == "core" ]]; then
        echo "core"
    elif [[ "$module_type" == "modules" ]]; then
        find "$DOTFILES_DIR/modules" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | sort
    else
        echo "core"
        find "$DOTFILES_DIR/modules" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | sort
    fi
}

# Module information
module_info() {
    local module=$1
    local module_dir
    
    if [[ "$module" == "core" ]]; then
        module_dir="$DOTFILES_DIR/core"
    else
        module_dir="$DOTFILES_DIR/modules/$module"
    fi
    
    if [[ -f "$module_dir/module.json" ]]; then
        cat "$module_dir/module.json"
    else
        echo "{}"
    fi
}

# Installation functions
install_module() {
    local module=$1
    local module_dir
    
    log INFO "Installing module: $module"
    
    if [[ "$module" == "core" ]]; then
        module_dir="$DOTFILES_DIR/core"
    else
        module_dir="$DOTFILES_DIR/modules/$module"
    fi
    
    if [[ ! -d "$module_dir" ]]; then
        log ERROR "Module not found: $module"
        return 1
    fi
    
    # Check if already installed
    if [[ $(json_get ".installed_modules.\"$module\".installed") == "true" ]]; then
        log WARN "Module already installed: $module"
        read -p "Reinstall? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            return 0
        fi
    fi
    
    # Create backup before installing
    backup_create "pre-install-$module"
    
    # Run module install script if exists
    # Prefer safe install script if available
    if [[ -f "$module_dir/install-safe.sh" ]]; then
        log INFO "Running safe module install script"
        (cd "$module_dir" && bash install-safe.sh)
    elif [[ -f "$module_dir/install.sh" ]]; then
        log INFO "Running module install script"
        (cd "$module_dir" && bash install.sh)
    fi
    
    # Update manifest
    local timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)
    json_set ".installed_modules.\"$module\"" "{\"installed\": true, \"version\": \"1.0.0\", \"installed_at\": \"$timestamp\"}"
    json_set ".last_updated" "\"$timestamp\""
    
    log SUCCESS "Module installed: $module"
}

# Uninstall functions
uninstall_module() {
    local module=$1
    
    log INFO "Uninstalling module: $module"
    
    # Check if installed
    if [[ $(json_get ".installed_modules.\"$module\".installed") != "true" ]]; then
        log WARN "Module not installed: $module"
        return 0
    fi
    
    # Create backup before uninstalling
    backup_create "pre-uninstall-$module"
    
    local module_dir
    if [[ "$module" == "core" ]]; then
        module_dir="$DOTFILES_DIR/core"
    else
        module_dir="$DOTFILES_DIR/modules/$module"
    fi
    
    # Run module uninstall script if exists
    # Prefer safe uninstall script if available
    if [[ -f "$module_dir/uninstall-safe.sh" ]]; then
        log INFO "Running safe module uninstall script"
        (cd "$module_dir" && bash uninstall-safe.sh)
    elif [[ -f "$module_dir/uninstall.sh" ]]; then
        log INFO "Running module uninstall script"
        (cd "$module_dir" && bash uninstall.sh)
    fi
    
    # Remove symlinks created by this module
    # TODO: Implement symlink tracking and removal
    
    # Update manifest
    json_set ".installed_modules.\"$module\".installed" "false"
    json_set ".last_updated" "\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\""
    
    log SUCCESS "Module uninstalled: $module"
}

# Backup functions
backup_create() {
    local name=${1:-manual}
    local timestamp=$(date +%Y%m%d-%H%M%S)
    local backup_name="${timestamp}-${name}"
    local backup_path="$BACKUP_DIR/$backup_name"
    
    log INFO "Creating backup: $backup_name"
    
    mkdir -p "$backup_path"
    
    # Copy manifest and symlinks
    cp "$MANIFEST_FILE" "$backup_path/manifest.json"
    cp "$SYMLINKS_FILE" "$backup_path/symlinks.json"
    
    # Use enhanced backup if available
    if [[ -f "$DOTFILES_DIR/scripts/backup.sh" ]]; then
        source "$DOTFILES_DIR/scripts/backup.sh"
        
        # Backup configurations for all installed modules
        for module in $(discover_modules); do
            if [[ $(json_get ".installed_modules.\"$module\".installed") == "true" ]]; then
                log INFO "Backing up configs for module: $module"
                
                # Get list of config files for this module
                local module_dir
                if [[ "$module" == "core" ]]; then
                    module_dir="$DOTFILES_DIR/core"
                else
                    module_dir="$DOTFILES_DIR/modules/$module"
                fi
                
                # Backup based on module.json if available
                if [[ -f "$module_dir/module.json" ]]; then
                    # Extract config files from module.json and backup
                    local configs=$(jq -r '.configs[]?.target // empty' "$module_dir/module.json" 2>/dev/null)
                    for config in $configs; do
                        # Expand ~ to $HOME
                        config="${config/#\~/$HOME}"
                        if [[ -e "$config" ]] || [[ -L "$config" ]]; then
                            backup_file "$config" "$backup_path"
                        fi
                    done
                fi
            fi
        done
        
        create_backup_manifest "$backup_path"
    fi
    
    # Update manifest with backup info
    local backup_info="{\"name\": \"$backup_name\", \"created_at\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\", \"type\": \"$name\"}"
    local temp=$(mktemp)
    jq ".backups += [$backup_info]" "$MANIFEST_FILE" > "$temp" && mv "$temp" "$MANIFEST_FILE"
    
    log SUCCESS "Backup created: $backup_name"
}

backup_list() {
    log INFO "Available backups:"
    
    for backup in "$BACKUP_DIR"/*; do
        if [[ -d "$backup" ]]; then
            local name=$(basename "$backup")
            local manifest="$backup/manifest.json"
            if [[ -f "$manifest" ]]; then
                local created=$(jq -r '.last_updated // "unknown"' "$manifest")
                echo "  - $name (created: $created)"
            fi
        fi
    done
}

# Restore functions
restore_backup() {
    local backup_name=$1
    
    if [[ -z "$backup_name" ]]; then
        backup_list
        read -p "Enter backup name to restore: " backup_name
    fi
    
    local backup_path="$BACKUP_DIR/$backup_name"
    
    if [[ ! -d "$backup_path" ]]; then
        log ERROR "Backup not found: $backup_name"
        return 1
    fi
    
    log WARN "This will restore the system to the state of backup: $backup_name"
    read -p "Continue? (y/N): " -n 1 -r
    echo
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log INFO "Restore cancelled"
        return 0
    fi
    
    # Create a backup of current state first
    backup_create "pre-restore"
    
    # Restore manifest and symlinks
    cp "$backup_path/manifest.json" "$MANIFEST_FILE"
    cp "$backup_path/symlinks.json" "$SYMLINKS_FILE"
    
    # Use enhanced restore if available
    if [[ -f "$DOTFILES_DIR/scripts/backup.sh" ]]; then
        source "$DOTFILES_DIR/scripts/backup.sh"
        
        # First uninstall all currently installed modules
        for module in $(discover_modules); do
            if [[ $(json_get ".installed_modules.\"$module\".installed") == "true" ]]; then
                log INFO "Uninstalling module before restore: $module"
                uninstall_module "$module"
            fi
        done
        
        # Restore all backed up configurations
        if [[ -f "$backup_path/MANIFEST.txt" ]]; then
            log INFO "Restoring configurations from backup..."
            
            # Extract unique file paths from manifest
            grep -E "^  " "$backup_path/MANIFEST.txt" | while read -r line; do
                local relative_path="${line#  }"
                local timestamp="${relative_path%%/*}"
                local file_path="${relative_path#*/}"
                
                # Skip manifest and symlink files
                if [[ "$file_path" == "MANIFEST.txt" ]] || [[ "$file_path" == *.symlink ]] || [[ "$file_path" == "manifest.json" ]] || [[ "$file_path" == "symlinks.json" ]]; then
                    continue
                fi
                
                local original_path="$HOME/$file_path"
                local backup_file="$backup_path/$relative_path"
                
                if [[ -e "$backup_file" ]] && [[ ! -f "$backup_file.symlink" ]]; then
                    mkdir -p "$(dirname "$original_path")"
                    cp -R "$backup_file" "$original_path" 2>/dev/null || true
                    log SUCCESS "Restored: $original_path"
                fi
            done
        fi
    fi
    
    log SUCCESS "Restored from backup: $backup_name"
}

# List installed modules
list_modules() {
    echo -e "${BLUE}Installed Modules:${NC}"
    echo
    
    local any_installed=false
    
    for module in $(discover_modules); do
        if [[ $(json_get ".installed_modules.\"$module\".installed") == "true" ]]; then
            local version=$(json_get ".installed_modules.\"$module\".version")
            local installed_at=$(json_get ".installed_modules.\"$module\".installed_at")
            echo -e "  ${GREEN}✓${NC} $module (v$version) - installed $installed_at"
            any_installed=true
        fi
    done
    
    if [[ "$any_installed" == "false" ]]; then
        echo "  No modules installed"
    fi
    
    echo
    echo -e "${BLUE}Available Modules:${NC}"
    echo
    
    for module in $(discover_modules); do
        if [[ $(json_get ".installed_modules.\"$module\".installed") != "true" ]]; then
            local info=$(module_info "$module")
            local desc=$(echo "$info" | jq -r '.description // "No description"')
            echo -e "  ${YELLOW}○${NC} $module - $desc"
        fi
    done
}

# Update modules
update_modules() {
    log INFO "Updating installed modules..."
    
    for module in $(discover_modules); do
        if [[ $(json_get ".installed_modules.\"$module\".installed") == "true" ]]; then
            log INFO "Updating module: $module"
            
            local module_dir
            if [[ "$module" == "core" ]]; then
                module_dir="$DOTFILES_DIR/core"
            else
                module_dir="$DOTFILES_DIR/modules/$module"
            fi
            
            if [[ -f "$module_dir/update.sh" ]]; then
                (cd "$module_dir" && bash update.sh)
            else
                log WARN "No update script for module: $module"
            fi
        fi
    done
    
    log SUCCESS "Update complete"
}

# Health check
doctor() {
    echo -e "${BLUE}Dotfiles Health Check${NC}"
    echo "===================="
    echo
    
    # Check directories
    echo "Checking directories..."
    for dir in "$STATE_DIR" "$BACKUP_DIR" "$LOG_DIR"; do
        if [[ -d "$dir" ]]; then
            echo -e "  ${GREEN}✓${NC} $dir"
        else
            echo -e "  ${RED}✗${NC} $dir (missing)"
        fi
    done
    echo
    
    # Check files
    echo "Checking state files..."
    for file in "$MANIFEST_FILE" "$SYMLINKS_FILE"; do
        if [[ -f "$file" ]]; then
            echo -e "  ${GREEN}✓${NC} $(basename $file)"
        else
            echo -e "  ${RED}✗${NC} $(basename $file) (missing)"
        fi
    done
    echo
    
    # Check installed modules
    echo "Checking installed modules..."
    local module_count=0
    for module in $(discover_modules); do
        if [[ $(json_get ".installed_modules.\"$module\".installed") == "true" ]]; then
            echo -e "  ${GREEN}✓${NC} $module"
            ((module_count++))
        fi
    done
    
    if [[ $module_count -eq 0 ]]; then
        echo -e "  ${YELLOW}!${NC} No modules installed"
    fi
    echo
    
    # Check for common issues
    echo "Checking for common issues..."
    
    # Check if jq is installed
    if command -v jq &> /dev/null; then
        echo -e "  ${GREEN}✓${NC} jq is installed"
    else
        echo -e "  ${RED}✗${NC} jq is not installed (required for JSON manipulation)"
    fi
    
    echo
    echo -e "${GREEN}Health check complete${NC}"
}

# Interactive installation
interactive_install() {
    echo -e "${BLUE}Interactive Module Installation${NC}"
    echo "==============================="
    echo
    
    local modules=()
    
    echo "Select modules to install (space to select, enter to confirm):"
    echo
    
    # Show core first
    echo -e "${PURPLE}Core Module:${NC}"
    echo "  [ ] core - Essential terminal setup (recommended)"
    modules+=("core")
    echo
    
    # Show optional modules
    echo -e "${PURPLE}Optional Modules:${NC}"
    for module in $(discover_modules modules); do
        local info=$(module_info "$module")
        local desc=$(echo "$info" | jq -r '.description // "No description"')
        echo "  [ ] $module - $desc"
        modules+=("$module")
    done
    
    # TODO: Implement actual interactive selection
    # For now, just prompt for module names
    echo
    read -p "Enter modules to install (comma-separated, or 'all'): " selected
    
    if [[ "$selected" == "all" ]]; then
        for module in "${modules[@]}"; do
            install_module "$module"
        done
    else
        IFS=',' read -ra SELECTED_MODULES <<< "$selected"
        for module in "${SELECTED_MODULES[@]}"; do
            module=$(echo "$module" | xargs)  # Trim whitespace
            install_module "$module"
        done
    fi
}

# Show usage
usage() {
    cat <<EOF
${BLUE}Modular Dotfiles Management System${NC}

Usage: $(basename $0) <command> [options]

Commands:
  install [modules]    Install modules (comma-separated or 'all')
  uninstall <module>   Uninstall a specific module
  list                 List installed and available modules
  update               Update all installed modules
  backup [name]        Create a backup of current state
  restore [name]       Restore from a backup
  doctor               Run health check
  help                 Show this help message

Examples:
  $(basename $0) install                    # Interactive installation
  $(basename $0) install core              # Install core module only
  $(basename $0) install core,devbox       # Install multiple modules
  $(basename $0) install all               # Install all available modules
  $(basename $0) uninstall devbox          # Remove devbox module
  $(basename $0) backup pre-experiment     # Create named backup
  $(basename $0) restore                   # Interactive restore

For more information, see README.md
EOF
}

# Main command dispatcher
main() {
    ensure_directories
    init_manifest
    init_symlinks
    
    local command=${1:-help}
    shift || true
    
    case $command in
        install)
            if [[ $# -eq 0 ]]; then
                interactive_install
            else
                IFS=',' read -ra MODULES <<< "$1"
                if [[ "$1" == "all" ]]; then
                    for module in $(discover_modules); do
                        install_module "$module"
                    done
                else
                    for module in "${MODULES[@]}"; do
                        module=$(echo "$module" | xargs)
                        install_module "$module"
                    done
                fi
            fi
            ;;
        uninstall)
            if [[ $# -eq 0 ]]; then
                log ERROR "Please specify a module to uninstall"
                exit 1
            fi
            uninstall_module "$1"
            ;;
        list)
            list_modules
            ;;
        update)
            update_modules
            ;;
        backup)
            backup_create "${1:-manual}"
            ;;
        restore)
            restore_backup "$1"
            ;;
        doctor)
            doctor
            ;;
        help|--help|-h)
            usage
            ;;
        *)
            log ERROR "Unknown command: $command"
            usage
            exit 1
            ;;
    esac
}

# Run main function
main "$@"