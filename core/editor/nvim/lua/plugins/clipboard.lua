-- Fix clipboard integration for system copy/paste
return {
  {
    "LazyVim/LazyVim",
    opts = {
      -- Enable system clipboard integration
      clipboard = "unnamedplus",
    },
  },

  -- Better clipboard behavior
  {
    "folke/which-key.nvim",
    opts = {
      defaults = {
        ["<leader>y"] = { name = "+yank to system" },
      },
    },
  },

  -- Add clipboard-specific keymaps
  {
    "nvim-lua/plenary.nvim",
    config = function()
      -- System clipboard operations
      vim.keymap.set({ "n", "v" }, "<leader>y", '"+y', { desc = "Yank to system clipboard" })
      vim.keymap.set("n", "<leader>Y", '"+Y', { desc = "Yank line to system clipboard" })
      vim.keymap.set({ "n", "v" }, "<leader>p", '"+p', { desc = "Paste from system clipboard" })
      vim.keymap.set({ "n", "v" }, "<leader>P", '"+P', { desc = "Paste before from system clipboard" })

      -- Mouse support with system clipboard
      vim.opt.mouse = "a"
      vim.opt.mousemodel = "popup"
      
      -- For terminal mode (if using terminal inside nvim)
      vim.keymap.set("t", "<C-v>", '<C-\\><C-n>"+pi', { desc = "Paste in terminal mode" })
    end,
  },
}