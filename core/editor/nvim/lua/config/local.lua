-- Local Neovim configuration overrides
-- This file is for personal customizations that won't be tracked in dotfiles

-- System clipboard integration
vim.opt.clipboard = "unnamedplus"

-- Better mouse support
vim.opt.mouse = "a"
vim.opt.mousemodel = "popup"

-- If on macOS, ensure clipboard works properly
if vim.fn.has("mac") == 1 then
  vim.g.clipboard = {
    name = "macOS-clipboard",
    copy = {
      ["+"] = "pbcopy",
      ["*"] = "pbcopy",
    },
    paste = {
      ["+"] = "pbpaste",
      ["*"] = "pbpaste",
    },
    cache_enabled = 0,
  }
end