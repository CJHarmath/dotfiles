#!/usr/bin/env bash
# AI Module Installation Script
# Provides a flexible framework for AI-powered development tools

set -euo pipefail

MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$(dirname "$MODULE_DIR")")"
CONFIG_DIR="$HOME/.config"
AI_CONFIG_DIR="$CONFIG_DIR/ai-tools"

source "$DOTFILES_DIR/scripts/utils.sh"

echo "Installing AI Module..."

# Create AI configuration directory
echo "Creating AI configuration directory..."
mkdir -p "$AI_CONFIG_DIR"/{shell-gpt,aider,ollama,templates}

# Detect OS
OS=$(detect_os)

# Interactive selection of AI tools
echo
echo "Select AI tools to install:"
echo
echo "Categories:"
echo "  1) Shell AI - Command line AI assistance"
echo "  2) Coding AI - AI pair programming tools"  
echo "  3) Local AI - Local AI models and runners"
echo "  4) Workflows - AI workflow automation"
echo "  5) All - Install recommended tools from all categories"
echo "  6) Minimal - Install basic shell AI only"
echo

read -p "Enter your choice (1-6): " choice

case $choice in
    1|6) INSTALL_CATEGORIES=("shell") ;;
    2) INSTALL_CATEGORIES=("coding") ;;
    3) INSTALL_CATEGORIES=("local") ;;
    4) INSTALL_CATEGORIES=("workflows") ;;
    5) INSTALL_CATEGORIES=("shell" "coding" "local" "workflows") ;;
    *) 
        echo "Invalid choice. Installing minimal setup."
        INSTALL_CATEGORIES=("shell")
        ;;
esac

# Install tools by category
for category in "${INSTALL_CATEGORIES[@]}"; do
    echo
    echo "Installing $category AI tools..."
    
    case $category in
        shell)
            install_shell_ai
            ;;
        coding)
            install_coding_ai
            ;;
        local)
            install_local_ai
            ;;
        workflows)
            install_workflow_ai
            ;;
    esac
done

# Install shell AI tools
install_shell_ai() {
    echo "Installing shell AI tools..."
    
    # Install shell-gpt
    if ! command_exists sgpt; then
        echo "Installing shell-gpt..."
        if command_exists pip3; then
            pip3 install shell-gpt --user
        elif command_exists pipx; then
            pipx install shell-gpt
        else
            log WARN "pip3 or pipx required for shell-gpt. Install manually with: pip install shell-gpt"
        fi
    fi
    
    # Install GitHub Copilot CLI if gh is available
    if command_exists gh; then
        echo "Installing GitHub Copilot CLI extension..."
        gh extension install github/gh-copilot || log WARN "Failed to install gh-copilot extension"
    fi
    
    # Create shell-gpt config
    safe_link "$MODULE_DIR/shell-gpt/sgptrc" "$CONFIG_DIR/shell_gpt/.sgptrc"
    
    # Add shell functions
    add_shell_ai_functions
}

# Install coding AI tools
install_coding_ai() {
    echo "Installing coding AI tools..."
    
    # Install aider
    if ! command_exists aider; then
        echo "Installing aider..."
        if command_exists pip3; then
            pip3 install aider-chat --user
        elif command_exists pipx; then
            pipx install aider-chat
        else
            log WARN "pip3 or pipx required for aider. Install manually with: pip install aider-chat"
        fi
    fi
    
    # Create aider config
    safe_link "$MODULE_DIR/aider/aider.conf.yml" "$HOME/.aider.conf.yml"
}

# Install local AI tools
install_local_ai() {
    echo "Installing local AI tools..."
    
    # Install Ollama
    if ! command_exists ollama; then
        echo "Installing Ollama..."
        if [[ "$OS" == "macos" ]]; then
            if command_exists brew; then
                brew install ollama
            else
                curl -fsSL https://ollama.ai/install.sh | sh
            fi
        else
            curl -fsSL https://ollama.ai/install.sh | sh
        fi
    fi
    
    # Create Ollama model templates
    create_ollama_templates
}

# Install workflow AI tools
install_workflow_ai() {
    echo "Installing workflow AI tools..."
    
    # Install fabric (if available)
    if command_exists go; then
        echo "Installing fabric..."
        go install github.com/danielmiessler/fabric@latest || log WARN "Failed to install fabric"
    fi
    
    log INFO "Workflow AI tools are highly experimental. Consider manual installation based on your needs."
}

# Add shell AI functions to zshrc
add_shell_ai_functions() {
    local zshrc="$HOME/.zshrc"
    local ai_functions_marker="# AI Module Functions"
    
    if [[ -f "$zshrc" ]] && ! grep -q "$ai_functions_marker" "$zshrc"; then
        cat >> "$zshrc" << EOF

$ai_functions_marker
# AI-powered shell functions

# Quick AI command suggestions
ai() {
    if command -v sgpt >/dev/null; then
        sgpt "\$*"
    elif command -v gh >/dev/null && gh extension list | grep -q copilot; then
        gh copilot suggest -t shell "\$*"
    else
        echo "No AI tools available. Install shell-gpt or gh copilot."
    fi
}

# AI code explanation
explain() {
    if command -v sgpt >/dev/null; then
        sgpt --role code "Explain this code: \$*"
    else
        echo "shell-gpt not available"
    fi
}

# AI code review
review() {
    local file=\${1:-}
    if [[ -z "\$file" ]]; then
        echo "Usage: review <file>"
        return 1
    fi
    
    if command -v sgpt >/dev/null; then
        sgpt --role code "Review this code for issues and improvements:" < "\$file"
    else
        echo "shell-gpt not available"
    fi
}

# AI commit message generation
aicommit() {
    if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        echo "Not in a git repository"
        return 1
    fi
    
    local diff=\$(git diff --cached)
    if [[ -z "\$diff" ]]; then
        echo "No staged changes found"
        return 1
    fi
    
    if command -v sgpt >/dev/null; then
        local message=\$(echo "\$diff" | sgpt --role commit "Generate a concise commit message for these changes:")
        echo "Suggested commit message:"
        echo "\$message"
        echo
        read -p "Use this message? (y/N): " -n 1 -r
        echo
        if [[ \$REPLY =~ ^[Yy]\$ ]]; then
            git commit -m "\$message"
        fi
    else
        echo "shell-gpt not available"
    fi
}

EOF
        log SUCCESS "Added AI shell functions to zshrc"
    fi
}

# Create Ollama model templates
create_ollama_templates() {
    local templates_dir="$MODULE_DIR/ollama/modelfile-templates"
    mkdir -p "$templates_dir"
    
    # Create a coding assistant Modelfile
    cat > "$templates_dir/coding-assistant.Modelfile" << 'EOF'
FROM llama2:7b

PARAMETER temperature 0.7
PARAMETER top_p 0.9

SYSTEM """
You are a helpful coding assistant. You provide clear, concise code examples and explanations. 
When asked to write code, you always include comments explaining what the code does.
You prefer modern, idiomatic solutions and best practices.
Keep responses focused and practical.
"""
EOF
    
    # Create a shell assistant Modelfile
    cat > "$templates_dir/shell-assistant.Modelfile" << 'EOF'
FROM llama2:7b

PARAMETER temperature 0.3
PARAMETER top_p 0.8

SYSTEM """
You are a command line assistant. You help users with shell commands, scripts, and system administration.
Always provide safe commands and explain any potentially dangerous operations.
Prefer standard POSIX commands when possible, but mention platform-specific alternatives when relevant.
Be concise but include safety warnings when appropriate.
"""
EOF
    
    log SUCCESS "Created Ollama model templates in $templates_dir"
}

# Create configuration files
echo "Creating configuration files..."

# Create AI tool configs directory structure
mkdir -p "$CONFIG_DIR"/{shell_gpt,aider}

# Link configuration files  
echo "Linking configuration files..."

# Create AI environment setup
cat > "$AI_CONFIG_DIR/env" << 'EOF'
# AI Tools Environment Configuration
# Source this file to set up AI tool environments

# Default AI provider (openai, anthropic, ollama, local)
export AI_PROVIDER=${AI_PROVIDER:-"auto"}

# Fallback to local AI when API is unavailable
export AI_FALLBACK=${AI_FALLBACK:-"ollama"}

# AI configuration directory
export AI_CONFIG_DIR="$HOME/.config/ai-tools"

# OpenAI API settings (if using)
# export OPENAI_API_KEY="your-key-here"
# export OPENAI_MODEL="gpt-4"

# Anthropic API settings (if using)
# export ANTHROPIC_API_KEY="your-key-here"

# Local AI settings
export OLLAMA_HOST=${OLLAMA_HOST:-"http://localhost:11434"}

# Shell-GPT settings
export SGPT_DEFAULT_MODEL=${SGPT_DEFAULT_MODEL:-"gpt-3.5-turbo"}

# Aider settings
export AIDER_MODEL=${AIDER_MODEL:-"gpt-4"}
EOF

# Source AI environment in zshrc
local zshrc="$HOME/.zshrc"
local ai_env_marker="# AI Environment Setup"

if [[ -f "$zshrc" ]] && ! grep -q "$ai_env_marker" "$zshrc"; then
    cat >> "$zshrc" << EOF

$ai_env_marker
# Load AI tools environment
if [[ -f "$AI_CONFIG_DIR/env" ]]; then
    source "$AI_CONFIG_DIR/env"
fi
EOF
fi

echo
echo "AI module installed successfully!"
echo
echo "What was installed:"
for category in "${INSTALL_CATEGORIES[@]}"; do
    case $category in
        shell) echo "  ✓ Shell AI: sgpt, gh-copilot, ai shell functions" ;;
        coding) echo "  ✓ Coding AI: aider for AI pair programming" ;;
        local) echo "  ✓ Local AI: ollama with model templates" ;;
        workflows) echo "  ✓ Workflow AI: fabric and automation tools" ;;
    esac
done

echo
echo "Next steps:"
echo "1. Restart your shell or run: source ~/.zshrc"
echo "2. Configure API keys in $AI_CONFIG_DIR/env if using cloud AI"
echo "3. For local AI: ollama serve (in another terminal)"
echo "4. Try: ai 'how to list files', explain 'ls -la', aicommit"
echo "5. For coding: Use 'aider' in your project directory"

if [[ " ${INSTALL_CATEGORIES[*]} " == *" local "* ]]; then
    echo
    echo "Ollama setup:"
    echo "  - Start Ollama: ollama serve"
    echo "  - Pull a model: ollama pull llama2:7b"
    echo "  - Create custom models: ollama create my-model -f modelfile"
fi