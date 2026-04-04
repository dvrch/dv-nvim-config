return {
  -- 🤖 MODERN COPILOT (Lua Version)
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    opts = {
      suggestion = { enabled = false }, -- Désactivé pour utiliser copilot-cmp
      panel = { enabled = false },
      filetypes = {
        markdown = true,
        help = true,
      },
    },
  },

  -- 🧩 COPILOT CMP INTEGRATION
  {
    "zbirenbaum/copilot-cmp",
    dependencies = "copilot.lua",
    config = function()
      require("copilot_cmp").setup()
    end,
  },

  -- 💬 COPILOT CHAT (Complet)
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    branch = "main",
    dependencies = {
      { "zbirenbaum/copilot.lua" },
      { "nvim-lua/plenary.nvim" },
    },
    opts = {
      debug = true,
      show_help = "yes",
      prompts = {
        Explain = "Explique moi comment fonctionne ce code Houdini / VEX",
        Review = "Fais une revue de code pour optimiser les performances",
        Fix = "Il y a une erreur dans ce script, peux-tu la corriger ?",
      },
    },
    keys = {
      { "<leader>ia", "<cmd>CopilotChatToggle<cr>", desc = "IA: Chat Copilot" },
      { "<leader>ie", "<cmd>CopilotChatExplain<cr>", desc = "IA: Expliquer Code" },
    },
  },

  -- 🦙 OLLAMA INTEGRATION (Local AI)
  {
    "David-Kunz/gen.nvim",
    opts = {
      model = "mistral", -- Modèle par défaut pour Ollama
      display_mode = "split",
      show_model = true,
      no_auto_close = true,
      init = function(options) pcall(io.popen, "ollama serve > /dev/null 2>&1 &") end,
      command = function(options)
        return "curl --silent --no-buffer -X POST http://localhost:11434/api/generate -d " .. vim.fn.json_encode(options)
      end,
    },
    keys = {
      { "<leader>io", ":Gen<cr>", desc = "IA: Ollama (Gen)", mode = { "n", "v" } },
    },
  },

  -- 🏗️ CONFIGURATION CMP (Pour l'auto-complétion IA)
  {
    "hrsh7th/nvim-cmp",
    opts = function(_, opts)
      local cmp = require("cmp")
      -- Priorité aux suggestions Copilot
      opts.sources = cmp.config.sources(vim.list_extend({
        { name = "copilot", group_index = 2 },
      }, opts.sources or {}))
    end,
  },
}
