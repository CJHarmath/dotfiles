-- Neovim Configuration
-- Based on LazyVim with sensible defaults

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Set leader keys before lazy
vim.g.mapleader = " "
vim.g.maplocalleader = ","

-- Setup lazy.nvim with LazyVim
require("lazy").setup({
  spec = {
    -- Import LazyVim base configuration
    { 
      "LazyVim/LazyVim", 
      import = "lazyvim.plugins",
      opts = {
        colorscheme = "catppuccin",
        defaults = {
          keymaps = true,
          autocmds = true,
        },
      },
    },
    
    -- Import LazyVim language modules (these are safe)
    { import = "lazyvim.plugins.extras.lang.typescript" },
    { import = "lazyvim.plugins.extras.lang.python" },
    { import = "lazyvim.plugins.extras.lang.json" },
    { import = "lazyvim.plugins.extras.lang.markdown" },
    
    -- Import custom plugins from lua/plugins directory if it exists
    { import = "plugins" },
  },
  defaults = {
    lazy = false,
    version = false,
  },
  install = { colorscheme = { "catppuccin", "tokyonight", "habamax" } },
  checker = { enabled = true },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})

-- Load local overrides if they exist
if vim.fn.filereadable(vim.fn.expand("~/.config/nvim/lua/config/local.lua")) == 1 then
  pcall(require, "config.local")
end