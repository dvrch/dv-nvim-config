return {
  "olimorris/codecompanion.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  opts = {
    adapters = {
      http = {
        openrouter = {
          schema = {
            model = {
              default = "deepseek/deepseek-chat-v3-0324:free",
            },
          },
        },
      },
    },

    strategies = {
      chat = {
        adapter = "ollama",
        keymaps = {
          send = { modes = { n = "<CR>", i = "<C-CR>" } },
          close = { modes = { n = "q", i = "<C-c>" } },
          next_chat = { modes = { n = "}" } },
          previous_chat = { modes = { n = "{" } },
          change_adapter = { modes = { n = "ga" } },
        },
      },
      inline = {
        adapter = "ollama",
      },
    },

    display = {
      chat = {
        window = {
          layout = "float",
          width = 0.8,
          height = 0.8,
        },
      },
    },

    opts = {
      log_level = "ERROR",
    },
  },

  keys = {
    { "<leader>co", "<cmd>CodeCompanionChat ollama<cr>", desc = "Chat Ollama" },
    { "<leader>cr", "<cmd>CodeCompanionChat openrouter<cr>", desc = "Chat OpenRouter" },
    { "<leader>ca", "<cmd>CodeCompanionActions<cr>", desc = "Actions IA" },
    { "<leader>aa", "<cmd>CodeCompanionActions<cr>", desc = "Actions IA", mode = { "n", "v" } },
  },
}
