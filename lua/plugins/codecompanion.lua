return {
  "olimorris/codecompanion.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  opts = {
    strategies = {
      chat = {
        adapter = "openrouter",
        keymaps = {
          send = { modes = { n = "<CR>", i = "<C-CR>" } },
          close = { modes = { n = "q", i = "<C-c>" } },
          next_chat = { modes = { n = "}" } },
          previous_chat = { modes = { n = "{" } },
          change_adapter = { modes = { n = "ga" } },
        },
      },
      inline = {
        adapter = "openrouter",
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

  config = function(_, opts)
    require("codecompanion").setup(opts)
    local openrouter = require("codecompanion.adapters.http.openrouter")
    openrouter.schema.model.default = "openrouter/free"
  end,

  keys = {
    { "<leader>cr", "<cmd>CodeCompanionChat openrouter<cr>", desc = "Chat OpenRouter" },
    { "<leader>ca", "<cmd>CodeCompanionActions<cr>", desc = "Actions IA" },
    { "<leader>aa", "<cmd>CodeCompanionActions<cr>", desc = "Actions IA", mode = { "n", "v" } },
  },
}
