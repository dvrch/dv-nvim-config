return {
  "olimorris/codecompanion.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  opts = {
    adapters = {
      http = {
        opts = {
          show_presets = false,
          allow_insecure = false,
          cache_models_for = 1800,
          show_model_choices = true,
        },
        openrouter = "openrouter",
      },
      acp = {
        opts = {
          show_presets = false,
        },
      },
    },
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
      agent = {
        adapter = "openrouter",
        keymaps = {
          send = { modes = { n = "<CR>", i = "<C-CR>" } },
          close = { modes = { n = "q", i = "<C-c>" } },
        },
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
      agent = {
        window = {
          layout = "float",
          width = 0.8,
          height = 0.8,
        },
      },
    },

    slash_commands = {
      ["buffer"] = { opts = { provider = "buffer" } },
      ["file"] = { opts = { provider = "file" } },
      ["help"] = { opts = { provider = "help" } },
      ["tools"] = { opts = { provider = "tools" } },
      ["symbols"] = { opts = { provider = "symbols" } },
    },

    opts = {
      log_level = "ERROR",
    },
  },

  config = function(_, opts)
    vim.env.OPENROUTER_API_KEY = "sk-or-v1-REMOVED"
    require("codecompanion").setup(opts)
    local openrouter = require("codecompanion.adapters.http.openrouter")
    openrouter.schema.model.default = "openrouter/free"
  end,

  keys = {
    { "<leader>cr", "<cmd>CodeCompanionChat openrouter<cr>", desc = "Chat OpenRouter" },
    { "<leader>ci", "<cmd>CodeCompanionInline<cr>", desc = "Inline IA", mode = { "n", "v" } },
    { "<leader>ca", "<cmd>CodeCompanionActions<cr>", desc = "Actions IA" },
    { "<leader>cg", "<cmd>CodeCompanionAgent<cr>", desc = "Agent IA" },
    { "<leader>aa", "<cmd>CodeCompanionActions<cr>", desc = "Actions IA", mode = { "n", "v" } },
  },
}
