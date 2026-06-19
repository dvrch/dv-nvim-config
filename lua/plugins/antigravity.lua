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
          -- 🦙 OLLAMA (Local)
          ollama = function()
            return require("codecompanion.adapters").extend("ollama", {
              schema = { model = { default = "llama3.2:3b-instruct-q4_K_S" } },
            })
          end,
        },
        strategies = {
          chat = { adapter = "ollama" },
          inline = { adapter = "ollama" },
          agent = { adapter = "ollama" },
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
          "  - <leader>ac : Lancer le Chat Ollama",
          "  - <leader>aa : Actions IA (Refactor, Fix...)",
          "  - <leader>im : Changer modèle Ollama local",
        }
        vim.notify(table.concat(help, "\n"), vim.log.levels.INFO)
      end, {})

      vim.keymap.set({ "n", "v" }, "<leader>aa", "<cmd>CodeCompanionActions<cr>", { desc = "IA: Antigravity Actions" })

      -- Ouvrir agy directement dans un terminal
      vim.keymap.set("n", "<leader>ia", function()
        vim.cmd("terminal agy")
        vim.cmd("startinsert")
      end, { desc = "IA: Terminal agy" })
    end,
  },
}
