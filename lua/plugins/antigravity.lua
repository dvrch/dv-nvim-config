return {
  {
    "olimorris/codecompanion.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "hrsh7th/nvim-cmp", -- Optional: For autocompletion
      "nvim-telescope/telescope.nvim", -- Optional: For searching and picking
      { "stevearc/dressing.nvim", opts = {} }, -- Optional: Better UI
    },
    config = function()
      require("codecompanion").setup({
        adapters = {
          -- 🧠 GOOGLE GEMINI (Le vrai cerveau Antigravity)
          gemini = function()
            return require("codecompanion.adapters").extend("gemini", {
              env = { api_key = os.getenv("GEMINI_API_KEY") },
              schema = { model = { default = "gemini-1.5-flash" } },
            })
          end,
          -- 🦙 OLLAMA (Local)
          ollama = function()
            return require("codecompanion.adapters").extend("ollama", {
              schema = { model = { default = "llama3.2:3b-instruct-q4_K_S" } },
            })
          end,
          -- 🌐 OPENROUTER (Multi-Model Cloud)
          openrouter = function()
            return require("codecompanion.adapters").extend("openai_compatible", {
              env = { api_key = "OPENROUTER_API_KEY" },
              url = "https://openrouter.ai/api/v1",
              schema = { model = { default = "anthropic/claude-3.5-sonnet" } },
            })
          end,
          -- 🏠 LM STUDIO (Local Server)
          lmstudio = function()
            return require("codecompanion.adapters").extend("openai_compatible", {
              url = "http://localhost:1234/v1",
              schema = { model = { default = "local-model" } },
            })
          end,
        },
        strategies = {
          chat = { adapter = "gemini" }, 
          inline = { adapter = "gemini" },
          agent = { adapter = "gemini" },
        },
      })
      
      -- FUNC: AIDE CONCISE IA
      vim.api.nvim_create_user_command("IAHelp", function()
        local help = {
          "🤖 AIDE CONCISE ANTIGRAVITY IA",
          "-----------------------------",
          "🚀 TEMPS RÉEL (Copilot) :",
          "  - <C-f> : Accepter suggestion grise",
          "  - <leader>it : Activer/Désactiver Copilot (Sleeping mode)",
          "💡 AGENTS & CHAT (Antigravity Brain) :",
          "  - <leader>ac : Lancer le Chat Gemini/Ollama",
          "  - <leader>aa : Actions IA (Refactor, Fix...)",
          "  - <leader>as : Changer de Cerveau (Universal Switcher)",
          "  - <leader>im : Changer modèle Ollama local",
          "🛠️ CONFIG APIs (dans ~/.zshrc) :",
          "  - export GEMINI_API_KEY=...",
          "  - export OPENROUTER_API_KEY=...",
        }
        vim.notify(table.concat(help, "\n"), vim.log.levels.INFO)
      end, {})

      vim.keymap.set({ "n", "v" }, "<leader>aa", "<cmd>CodeCompanionActions<cr>", { desc = "IA: Antigravity Actions" })
    end,
  },
}
