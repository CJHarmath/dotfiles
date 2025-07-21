#!/usr/bin/env zsh
# 60-tools.zsh - Modern tool integrations

# Zoxide (smart cd) - must be after compinit
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi

# Atuin (better history)
if command -v atuin >/dev/null 2>&1; then
  eval "$(atuin init zsh)"
fi

# Starship prompt
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi

# Direnv (if installed via devbox module)
if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook zsh)"
fi

# Mise (if installed via devbox module)
if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate zsh)"
fi

# GitHub CLI completion
if command -v gh >/dev/null 2>&1; then
  eval "$(gh completion -s zsh)"
fi

# 1Password CLI completion (if installed)
if command -v op >/dev/null 2>&1; then
  eval "$(op completion zsh)"
  compdef _op op
fi

# AWS CLI completion (if installed)
if command -v aws_completer >/dev/null 2>&1; then
  complete -C aws_completer aws
fi

# kubectl completion (if installed)
if command -v kubectl >/dev/null 2>&1; then
  source <(kubectl completion zsh)
fi

# Terraform completion (if installed)
if command -v terraform >/dev/null 2>&1; then
  complete -o nospace -C terraform terraform
fi