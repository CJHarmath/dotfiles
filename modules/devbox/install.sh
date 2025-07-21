#!/usr/bin/env bash
# Devbox Module Installation Script
# Installs devbox, direnv, just, and mise for reproducible development environments

set -euo pipefail

MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$(dirname "$MODULE_DIR")")"
CONFIG_DIR="$HOME/.config"

source "$DOTFILES_DIR/scripts/utils.sh"

echo "Installing Devbox Module..."

# Detect OS
OS=$(detect_os)

# Install packages
echo "Installing packages..."

if [[ "$OS" == "macos" ]]; then
    # Install via Homebrew
    brew install direnv just mise-en-place
    
    # Install devbox
    if ! command_exists devbox; then
        echo "Installing devbox..."
        curl -fsSL https://get.jetpack.io/devbox | bash
    fi
elif [[ "$OS" == "fedora" ]]; then
    # Install direnv via package manager
    sudo dnf install -y direnv
    
    # Install just via cargo
    if ! command_exists just; then
        cargo install just
    fi
    
    # Install mise
    if ! command_exists mise; then
        curl https://mise.run | sh
    fi
    
    # Install devbox
    if ! command_exists devbox; then
        echo "Installing devbox..."
        curl -fsSL https://get.jetpack.io/devbox | bash
    fi
else
    echo "Installing tools for $OS..."
    
    # Install direnv
    if ! command_exists direnv; then
        echo "Installing direnv..."
        if command_exists apt-get; then
            sudo apt-get update && sudo apt-get install -y direnv
        elif command_exists pacman; then
            sudo pacman -S direnv
        else
            # Fallback to manual installation
            local direnv_version="v2.32.3"
            local arch=$(uname -m)
            case $arch in
                x86_64) arch="amd64" ;;
                aarch64) arch="arm64" ;;
            esac
            curl -sfL "https://github.com/direnv/direnv/releases/download/$direnv_version/direnv.linux-$arch" -o "$HOME/.local/bin/direnv"
            chmod +x "$HOME/.local/bin/direnv"
        fi
    fi
    
    # Install just via cargo
    if ! command_exists just; then
        cargo install just
    fi
    
    # Install mise
    if ! command_exists mise; then
        curl https://mise.run | sh
    fi
    
    # Install devbox
    if ! command_exists devbox; then
        echo "Installing devbox..."
        curl -fsSL https://get.jetpack.io/devbox | bash
    fi
fi

# Create config directories
echo "Creating configuration directories..."
mkdir -p "$CONFIG_DIR"/{direnv,mise}

# Link configurations
echo "Linking configurations..."
safe_link "$MODULE_DIR/direnv/direnvrc" "$CONFIG_DIR/direnv/direnvrc"
safe_link "$MODULE_DIR/mise/config.toml" "$CONFIG_DIR/mise/config.toml"

# Add shell integrations to zshrc if not already present
echo "Adding shell integrations..."

ZSHRC="$HOME/.zshrc"
if [[ -f "$ZSHRC" ]]; then
    # Add direnv hook
    if ! grep -q "eval.*direnv hook" "$ZSHRC"; then
        echo '' >> "$ZSHRC"
        echo '# Devbox module integrations' >> "$ZSHRC"
        echo 'eval "$(direnv hook zsh)"' >> "$ZSHRC"
        log SUCCESS "Added direnv hook to zshrc"
    fi
    
    # Add mise hook
    if ! grep -q "eval.*mise activate" "$ZSHRC"; then
        echo 'eval "$(mise activate zsh)"' >> "$ZSHRC"
        log SUCCESS "Added mise hook to zshrc"
    fi
else
    log WARN "No .zshrc found. Please add shell integrations manually."
fi

# Create example devbox project
echo "Creating example devbox project..."
EXAMPLE_DIR="$HOME/.dotfiles-examples/devbox-example"
mkdir -p "$EXAMPLE_DIR"

cat > "$EXAMPLE_DIR/devbox.json" <<'EOF'
{
  "packages": [
    "nodejs@18",
    "python@3.11",
    "go@1.21"
  ],
  "shell": {
    "init_hook": [
      "echo 'Welcome to your devbox environment!'",
      "echo 'Available tools: node, python, go'"
    ]
  },
  "nixpkgs": {
    "commit": "nixos-23.05"
  }
}
EOF

cat > "$EXAMPLE_DIR/.envrc" <<'EOF'
# Automatically activate devbox environment
eval "$(devbox generate direnv)"
EOF

cat > "$EXAMPLE_DIR/justfile" <<'EOF'
# Example justfile for project automation
default:
    @just --list

# Setup the development environment
setup:
    devbox shell -- npm install
    devbox shell -- pip install -r requirements.txt

# Run tests
test:
    devbox shell -- npm test
    devbox shell -- python -m pytest

# Start development server
dev:
    devbox shell -- npm run dev

# Clean build artifacts
clean:
    rm -rf node_modules dist build __pycache__
    
# Show environment info
info:
    devbox info
    devbox services ls
EOF

cat > "$EXAMPLE_DIR/README.md" <<'EOF'
# Devbox Example Project

This is an example project using devbox for reproducible development environments.

## Getting Started

1. Navigate to this directory: `cd ~/.dotfiles-examples/devbox-example`
2. Allow direnv: `direnv allow`
3. The devbox environment will be automatically activated
4. Run `just setup` to install dependencies
5. Run `just dev` to start the development server

## Available Commands

- `just` - Show available commands
- `just setup` - Setup development environment
- `just test` - Run tests
- `just dev` - Start development server
- `just clean` - Clean build artifacts
- `just info` - Show environment information

## Tools Available in this Environment

- Node.js 18
- Python 3.11
- Go 1.21

These tools are isolated to this project and won't conflict with your system versions.
EOF

# Allow the .envrc in the example
if command_exists direnv; then
    (cd "$EXAMPLE_DIR" && direnv allow 2>/dev/null || true)
fi

log SUCCESS "Created example project at $EXAMPLE_DIR"

echo
echo "Devbox module installed successfully!"
echo
echo "What was installed:"
echo "  ✓ devbox - Portable development environments"
echo "  ✓ direnv - Automatic environment switching"
echo "  ✓ just - Command runner and build tool"
echo "  ✓ mise - Polyglot version management"
echo
echo "Next steps:"
echo "1. Restart your shell or run: source ~/.zshrc"
echo "2. Check out the example project: cd ~/.dotfiles-examples/devbox-example"
echo "3. Try: devbox --help, direnv --help, just --help, mise --help"
echo "4. Create a devbox.json in your project: devbox init"