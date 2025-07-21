# Core Module - Safe Installation

The core module provides essential terminal tools with a **safe, reversible** installation process.

## Drop-in Architecture

Instead of overwriting files, we use drop-in configurations wherever possible:

### Zsh Configuration
- Main `.zshrc` only sources drop-in files from `~/.config/zsh/conf.d/`
- Each aspect of configuration is in its own file
- Easy to disable/debug individual components
- Modules can add their own files to `~/.config/zsh/modules/`

### Neovim Configuration  
- Minimal `init.lua` that loads LazyVim
- Additional plugins in `lua/plugins/` directory
- Local overrides in `~/.config/nvim/lua/config/local.lua`

## Safe Installation

Use the safe installation scripts:

```bash
# Install with proper backups
./install-safe.sh

# Uninstall and restore from backups
./uninstall-safe.sh
```

### What the safe installer does:

1. **Creates timestamped backup** of all files that will be modified
2. **Shows what will be changed** before proceeding
3. **Tracks all symlinks** created during installation
4. **Saves installation record** for clean uninstall
5. **Can restore from backup** during uninstall

### Backup locations:
- Backups: `~/.dotfiles-backups/YYYYMMDD-HHMMSS-core-install/`
- Install record: `~/.dotfiles/state/core-install-record.json`
- Symlink list: saved with each backup

## Configuration Files

### Drop-in configs (non-destructive):
- `~/.config/zsh/conf.d/*.zsh` - Zsh configuration modules
- `~/.config/nvim/lua/plugins/*.lua` - Neovim plugin configs
- `~/.zshrc.local` - Local overrides
- `~/.config/nvim/lua/config/local.lua` - Local Neovim config

### Symlinked configs (with backups):
- `~/.zshrc` - Main shell configuration
- `~/.gitconfig` - Git configuration  
- `~/.tmux.conf` - Tmux configuration
- Other tool configs in `~/.config/`

## Troubleshooting

### Zsh issues:
```bash
# Disable a specific config
mv ~/.config/zsh/conf.d/50-problem.zsh ~/.config/zsh/conf.d/50-problem.zsh.disabled

# Check which file causes issues
for f in ~/.config/zsh/conf.d/*.zsh; do
  echo "Testing $f"
  zsh -c "source $f"
done
```

### Neovim issues:
```bash
# Reset Neovim completely
rm -rf ~/.local/share/nvim
rm -rf ~/.cache/nvim

# Start fresh
nvim
```

### Restore from backup:
```bash
# Full restoration
./uninstall-safe.sh

# Or restore individual files
cp ~/.dotfiles-backups/*/PATH/TO/FILE ~/PATH/TO/FILE
```

## Philosophy

1. **Never destroy user data** - Always backup first
2. **Make it reversible** - Every change can be undone
3. **Use drop-ins** - Extend rather than replace
4. **Track everything** - Know what was changed
5. **Safe by default** - Require confirmation for destructive actions