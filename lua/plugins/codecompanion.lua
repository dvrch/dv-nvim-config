return {
  "olimorris/codecompanion.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  opts = {
    adapters = {
      openrouter = function()
        return require("codecompanion.adapters").extend("openai", {
          name = "openrouter",
          url = "https://openrouter.ai/api/v1/chat/completions",
          env = {
            api_key = vim.env.OPENROUTER_API_KEY,
          },
          schema = {
            model = {
              default = "deepseek/deepseek-chat-v3-0324:free",
            },
          },
        })
      end,
    },
    strategies = {
      chat = {
        adapter = "openrouter",
      },
      inline = {
        adapter = "openrouter",
      },
    },
  },
  keys = {
    { "<leader>ic", "<cmd>CodeCompanionChat<cr>", desc = "IA: Chat OpenRouter" },
    { "<leader>ia", "<cmd>CodeCompanionActions<cr>", desc = "IA: Actions IA" },
    { "<leader>ip", "<cmd>CodeCompanion<cr>", desc = "IA: Prompt OpenRouter" },
  },
}
