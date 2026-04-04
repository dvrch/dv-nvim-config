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

  -- 🦙 OLLAMA (Local AI / Gen)
  {
    "David-Kunz/gen.nvim",
    opts = {
      model = "llama3.2:3b-instruct-q4_K_S", -- Ton nouveau modèle par défaut !
      display_mode = "float",
    },
    config = function(_, opts)
        require("gen").setup(opts)
        
        -- FUNC: Sélecteur de modèle Ollama interactif
        vim.api.nvim_create_user_command("IASelectModel", function()
          local handle = io.popen("ollama list | awk 'NR>1 {print $1}'")
          local result = handle:read("*a")
          handle:close()
          local models = vim.split(result, "\n", { trimempty = true })
          
          vim.ui.select(models, { prompt = "🦙 Choisir le modèle Ollama :" }, function(choice)
            if choice then
              require("gen").model = choice
              vim.notify("Modèle Ollama réglé sur : " .. choice .. " ✅", vim.log.levels.INFO)
            end
          end)
        end, {})
    end,
    keys = {
      { "<leader>io", ":Gen<cr>", desc = "IA: Ollama Actions", mode = { "n", "v" } },
      { "<leader>im", "<cmd>IASelectModel<cr>", desc = "IA: Choisir modèle Ollama" },
      { "<leader>it", "<cmd>IAToggleCopilot<cr>", desc = "IA: Basculer Copilot Réel" },
      { "<leader>ic", "<cmd>CodeCompanionChat<cr>", desc = "IA: Antigravity Chat" },
      { "<leader>is", "<cmd>CodeCompanionCombo<cr>", desc = "IA: Switch Brain" },
      { "<leader>ip", "<cmd>edit /home/kd/scripts/agent_brain.ipynb<cr>", desc = "IA: Pont Agent (.ipynb)" },
      { "<leader>ih", "<cmd>IAHelp<cr>", desc = "IA: Aide Concise" },
    },
  },

  -- 💬 COPILOT CHAT (Side Window)
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    branch = "main",
    dependencies = {
      { "zbirenbaum/copilot.lua" },
      { "nvim-lua/plenary.nvim" },
    },
    opts = {
      window = {
        layout = "float",
        width = 0.8,
        height = 0.8,
      },
    },
    keys = {
      { "<leader>ia", "<cmd>CopilotChatToggle<cr>", desc = "IA: Chat Copilot" },
    },
  },
}
