#!/usr/bin/env bash
# Utility functions for dotfiles management

set -euo pipefail

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
    
    case $level in
        ERROR) echo -e "${RED}[ERROR]${NC} $message" >&2 ;;
        WARN)  echo -e "${YELLOW}[WARN]${NC} $message" ;;
        INFO)  echo -e "${BLUE}[INFO]${NC} $message" ;;
        SUCCESS) echo -e "${GREEN}[✓]${NC} $message" ;;
        *) echo "$message" ;;
    esac
}

# OS Detection
detect_os() {
    case "$(uname -s)" in
        Darwin) echo "macos" ;;
        Linux)
            if [[ -f /etc/fedora-release ]]; then
                echo "fedora"
            elif [[ -f /etc/debian_version ]]; then
                echo "debian"
            elif [[ -f /etc/arch-release ]]; then
                echo "arch"
            else
                echo "linux"
            fi
            ;;
        *) echo "unknown" ;;
    esac
}

# Check if command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Safe symlink creation with backup
safe_link() {
    local src=$1
    local dst=$2
    local backup_suffix=${3:-backup}
    
    # Create parent directory if needed
    mkdir -p "$(dirname "$dst")"
    
    # Backup existing file/directory if not a symlink
    if [[ -e "$dst" ]] && [[ ! -L "$dst" ]]; then
        local backup="$dst.$backup_suffix.$(date +%s)"
        log WARN "Backing up existing file: $dst -> $backup"
        mv "$dst" "$backup"
    fi
    
    # Remove existing symlink
    if [[ -L "$dst" ]]; then
        rm "$dst"
    fi
    
    # Create new symlink
    ln -sf "$src" "$dst"
    log SUCCESS "Linked: $src -> $dst"
}

# Remove symlink and restore backup
safe_unlink() {
    local link=$1
    local backup_pattern="$link.backup."
    
    if [[ -L "$link" ]]; then
        rm "$link"
        log SUCCESS "Removed symlink: $link"
        
        # Find and restore most recent backup
        local backup=$(find "$(dirname "$link")" -name "$(basename "$link").backup.*" -type f 2>/dev/null | sort -V | tail -1)
        if [[ -n "$backup" ]]; then
            mv "$backup" "$link"
            log SUCCESS "Restored backup: $backup -> $link"
        fi
    elif [[ -e "$link" ]]; then
        log WARN "File exists but is not a symlink: $link"
    else
        log INFO "No file to remove: $link"
    fi
}

# JSON manipulation helpers
json_get() {
    local key=$1
    local file=$2
    jq -r "$key" "$file" 2>/dev/null || echo ""
}

json_set() {
    local key=$1
    local value=$2
    local file=$3
    local temp=$(mktemp)
    jq "$key = $value" "$file" > "$temp" && mv "$temp" "$file"
}

json_add_array() {
    local key=$1
    local value=$2
    local file=$3
    local temp=$(mktemp)
    jq "$key += [$value]" "$file" > "$temp" && mv "$temp" "$file"
}

# Backup configuration files
backup_configs() {
    local backup_dir=$1
    local configs_to_backup=(
        "$HOME/.zshrc"
        "$HOME/.zshenv"
        "$HOME/.gitconfig"
        "$HOME/.tmux.conf"
        "$HOME/.config/nvim"
        "$HOME/.config/wezterm"
        "$HOME/.config/zellij"
        "$HOME/.config/starship.toml"
        "$HOME/.config/bat"
        "$HOME/.config/atuin"
    )
    
    mkdir -p "$backup_dir/configs"
    
    for config in "${configs_to_backup[@]}"; do
        if [[ -e "$config" ]]; then
            local relative_path=${config#$HOME/}
            local backup_path="$backup_dir/configs/$relative_path"
            mkdir -p "$(dirname "$backup_path")"
            
            if [[ -L "$config" ]]; then
                # For symlinks, store the target
                readlink "$config" > "$backup_path.symlink"
            else
                # For regular files/directories, copy them
                cp -R "$config" "$backup_path"
            fi
            
            log INFO "Backed up: $config"
        fi
    done
}

# Restore configuration files
restore_configs() {
    local backup_dir=$1
    local configs_dir="$backup_dir/configs"
    
    if [[ ! -d "$configs_dir" ]]; then
        log ERROR "No configs directory found in backup"
        return 1
    fi
    
    # Find all backed up configs
    find "$configs_dir" -type f -o -type d | while read -r backup_path; do
        local relative_path=${backup_path#$configs_dir/}
        local restore_path="$HOME/$relative_path"
        
        # Skip if it's a symlink file
        if [[ "$backup_path" == *.symlink ]]; then
            continue
        fi
        
        # Check if there's a corresponding symlink file
        if [[ -f "$backup_path.symlink" ]]; then
            # Restore as symlink
            local target=$(cat "$backup_path.symlink")
            safe_link "$target" "$restore_path" "pre-restore"
        else
            # Restore as regular file/directory
            mkdir -p "$(dirname "$restore_path")"
            if [[ -e "$restore_path" ]]; then
                mv "$restore_path" "$restore_path.pre-restore.$(date +%s)"
            fi
            cp -R "$backup_path" "$restore_path"
        fi
        
        log SUCCESS "Restored: $restore_path"
    done
}

# Package management helpers
install_package() {
    local package=$1
    local os=${2:-$(detect_os)}
    
    case $os in
        macos)
            if command_exists brew; then
                brew install "$package"
            else
                log ERROR "Homebrew not installed"
                return 1
            fi
            ;;
        fedora)
            sudo dnf install -y "$package"
            ;;
        debian)
            sudo apt-get update && sudo apt-get install -y "$package"
            ;;
        arch)
            sudo pacman -S --noconfirm "$package"
            ;;
        *)
            log ERROR "Unsupported OS for package installation: $os"
            return 1
            ;;
    esac
}

# Check if package is installed
package_installed() {
    local package=$1
    local os=${2:-$(detect_os)}
    
    case $os in
        macos)
            brew list "$package" &> /dev/null
            ;;
        fedora)
            dnf list installed "$package" &> /dev/null
            ;;
        debian)
            dpkg -l "$package" &> /dev/null
            ;;
        arch)
            pacman -Q "$package" &> /dev/null
            ;;
        *)
            # Fallback: check if command exists
            command_exists "$package"
            ;;
    esac
}

# Network connectivity check
check_connectivity() {
    local host=${1:-google.com}
    local timeout=${2:-5}
    
    if command_exists curl; then
        curl -s --connect-timeout "$timeout" --max-time "$timeout" "$host" > /dev/null
    elif command_exists wget; then
        wget -q --timeout="$timeout" --tries=1 --spider "$host"
    elif command_exists ping; then
        ping -c 1 -W "$timeout" "$host" > /dev/null
    else
        log WARN "No network connectivity check tools available"
        return 1
    fi
}

# Prompt for confirmation
confirm() {
    local message=${1:-"Continue?"}
    local default=${2:-"N"}
    
    if [[ "$default" == "Y" ]]; then
        read -p "$message (Y/n): " -n 1 -r
        echo
        [[ -z $REPLY ]] || [[ $REPLY =~ ^[Yy]$ ]]
    else
        read -p "$message (y/N): " -n 1 -r
        echo
        [[ $REPLY =~ ^[Yy]$ ]]
    fi
}

# Get user input with default
get_input() {
    local prompt=$1
    local default=$2
    local input
    
    read -p "$prompt [$default]: " input
    echo "${input:-$default}"
}

# Spinner for long-running operations
spinner() {
    local pid=$1
    local message=${2:-"Working..."}
    local delay=0.1
    local spinstr='|/-\'
    
    while kill -0 "$pid" 2>/dev/null; do
        local temp=${spinstr#?}
        printf "\r$message %c  " "$spinstr"
        spinstr=$temp${spinstr%"$temp"}
        sleep $delay
    done
    printf "\r$message ✓  \n"
}

# Run command with spinner
run_with_spinner() {
    local message=$1
    shift
    local cmd=("$@")
    
    "${cmd[@]}" &
    local pid=$!
    spinner $pid "$message"
    wait $pid
    return $?
}