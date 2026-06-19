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
            api_key = os.getenv("OPENROUTER_API_KEY") or "",
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

  config = function(_, opts)
    require("codecompanion").setup(opts)

    -- OpenRouter models list
    local openrouter_models = {
      "deepseek/deepseek-chat-v3-0324:free",
      "meta-llama/llama-4-maverick:free",
      "qwen/qwen3-235b-a22b:free",
      "google/gemma-3-27b-it:free",
      "microsoft/phi-4-reasoning:free",
      "nvidia/llama-3.1-nemotron-ultra-253b-v1:free",
    }

    -- Select OpenRouter model
    vim.api.nvim_create_user_command("IASelectOpenRouter", function()
      vim.ui.select(openrouter_models, {
        prompt = "🌐 Choisir le modèle OpenRouter :",
      }, function(choice)
        if choice then
          vim.notify("Modèle OpenRouter : " .. choice, vim.log.levels.INFO)
          vim.cmd("CodeCompanionChat openrouter")
          vim.api.nvim_feedkeys("/model " .. choice .. "\n", "n", false)
        end
      end)
    end, {})

    -- Select Ollama model
    vim.api.nvim_create_user_command("IASelectOllama", function()
      local handle = io.popen("ollama list | awk 'NR>1 {print $1}'")
      local result = handle:read("*a")
      handle:close()
      local models = vim.split(result, "\n", { trimempty = true })
      
      vim.ui.select(models, {
        prompt = "🦙 Choisir le modèle Ollama :",
      }, function(choice)
        if choice then
          vim.notify("Modèle Ollama : " .. choice, vim.log.levels.INFO)
          vim.cmd("CodeCompanionChat ollama")
          vim.api.nvim_feedkeys("/model " .. choice .. "\n", "n", false)
        end
      end)
    end, {})
  end,

  keys = {
    { "<leader>cc", "<cmd>CodeCompanionChat<cr>", desc = "IA: Chat" },
    { "<leader>co", "<cmd>CodeCompanionChat ollama<cr>", desc = "IA: Chat Ollama" },
    { "<leader>cr", "<cmd>CodeCompanionChat openrouter<cr>", desc = "IA: Chat OpenRouter" },
    { "<leader>ca", "<cmd>CodeCompanionActions<cr>", desc = "IA: Actions" },
    { "<leader>im", "<cmd>IASelectOllama<cr>", desc = "IA: Modèle Ollama" },
    { "<leader>ir", "<cmd>IASelectOpenRouter<cr>", desc = "IA: Modèle OpenRouter" },
  },
}
