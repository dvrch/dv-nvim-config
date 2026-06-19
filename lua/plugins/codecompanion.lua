return {
  "olimorris/codecompanion.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  opts = {
    adapters = {
      -- Ollama (local)
      ollama = function()
        return require("codecompanion.adapters").extend("ollama", {
          name = "ollama",
          schema = {
            model = {
              default = "qwen3:latest",
            },
          },
        })
      end,

      -- OpenRouter (cloud)
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
        adapter = "ollama",
      },
      inline = {
        adapter = "ollama",
      },
    },
  },

  keys = {
    { "<leader>cc", "<cmd>CodeCompanionChat<cr>", desc = "IA: Chat" },
    { "<leader>co", "<cmd>CodeCompanionChat ollama<cr>", desc = "IA: Chat Ollama" },
    { "<leader>cr", "<cmd>CodeCompanionChat openrouter<cr>", desc = "IA: Chat OpenRouter" },
    { "<leader>ca", "<cmd>CodeCompanionActions<cr>", desc = "IA: Actions" },
  },
}
