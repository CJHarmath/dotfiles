-- AI plugins configuration
-- These are optional and can be removed if not needed

return {
  -- GitHub Copilot (requires subscription)
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    enabled = vim.fn.executable("node") == 1,
    config = function()
      require("copilot").setup({
        suggestion = { 
          enabled = true,
          auto_trigger = true,
          keymap = {
            accept = "<Tab>",
            next = "<M-]>",
            prev = "<M-[>",
            dismiss = "<C-]>",
          },
        },
        panel = { enabled = true },
      })
    end,
  },
  
  -- Copilot integration with blink.cmp
  -- Note: copilot-cmp is not compatible with blink.cmp
  -- Copilot suggestions will work directly through copilot.lua
  
  -- Codeium (free alternative to Copilot)
  -- Uncomment to use Codeium instead of Copilot
  -- {
  --   "Exafunction/codeium.nvim",
  --   dependencies = {
  --     "nvim-lua/plenary.nvim",
  --     "hrsh7th/nvim-cmp",
  --   },
  --   event = "BufEnter",
  --   config = function()
  --     require("codeium").setup({
  --       enable_chat = true,
  --     })
  --   end,
  -- },
}