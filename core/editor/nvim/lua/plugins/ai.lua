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
        suggestion = { enabled = false },
        panel = { enabled = false },
      })
    end,
  },
  
  -- Copilot integration with nvim-cmp
  {
    "zbirenbaum/copilot-cmp",
    dependencies = "copilot.lua",
    opts = {},
    config = function(_, opts)
      local copilot_cmp = require("copilot_cmp")
      copilot_cmp.setup(opts)
      -- Add copilot as a source for nvim-cmp
      LazyVim.on_load("nvim-cmp", function()
        require("cmp").setup.buffer({
          sources = {
            { name = "copilot" },
            { name = "nvim_lsp" },
            { name = "buffer" },
            { name = "path" },
          },
        })
      end)
    end,
  },
  
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