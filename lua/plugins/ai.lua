return {
  -- 🤖 MODERN COPILOT (Lua Version)
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    lazy = false,
    opts = {
      suggestion = {
        enabled = true,
        auto_trigger = true,
        keymap = {
          accept = "<C-f>",
          accept_word = "<C-k>",
          next = "<C-j>",
          prev = "<C-h>",
          dismiss = "<C-q>",
        },
      },
      panel = { enabled = true },
      filetypes = { ["*"] = true },
    },
    config = function(_, opts)
      require("copilot").setup(opts)
      
      -- FUNC: Toggle Copilot (On/Off)
      vim.api.nvim_create_user_command("IAToggleCopilot", function()
        local client = require("copilot.client")
        if client.is_disabled() then
          vim.cmd("Copilot enable")
          vim.notify("Copilot ACTIVÉ 🦾", vim.log.levels.INFO)
        else
          vim.cmd("Copilot disable")
          vim.notify("Copilot DÉSACTIVÉ 🛌", vim.log.levels.WARN)
        end
      end, {})
    end,
  },

  -- 🏗️ CONFIGURATION CMP (Menu / Auto-completion)
  {
    "hrsh7th/nvim-cmp",
    dependencies = { "zbirenbaum/copilot-cmp" },
    opts = function(_, opts)
      local cmp = require("cmp")
      require("copilot_cmp").setup()
      table.insert(opts.sources, { name = "copilot", priority = 1000 })
    end,
  },

}
