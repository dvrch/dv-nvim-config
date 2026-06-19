return {
  "olimorris/codecompanion.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  opts = {
    -- Multi-chat: chaque session est un buffer séparé
    display = {
      chat = {
        window = {
          layout = "float",
          width = 0.8,
          height = 0.8,
        },
      },
    },

    adapters = {
      -- Ollama (local)
      ollama = function()
        return require("codecompanion.adapters").extend("ollama", {
          name = "ollama",
          schema = {
            model = { default = "qwen3:latest" },
          },
        })
      end,

      -- OpenRouter (cloud)
      openrouter = function()
        local api_key = os.getenv("OPENROUTER_API_KEY")
        if not api_key or api_key == "" then
          vim.notify("⚠️ OPENROUTER_API_KEY non définie dans .bashrc", vim.log.levels.WARN)
        end
        return require("codecompanion.adapters").extend("openai", {
          name = "openrouter",
          url = "https://openrouter.ai/api/v1/chat/completions",
          api_key = api_key or "",
          schema = {
            model = {
              default = "deepseek/deepseek-chat-v3-0324:free",
              opts = {}, -- permet de changer de modèle dans le chat
            },
          },
          headers = {
            ["HTTP-Referer"] = "https://github.com/olimorris/codecompanion.nvim",
            ["X-Title"] = "Neovim",
          },
        })
      end,
    },

    strategies = {
      chat = {
        adapter = "ollama",
        keymaps = {
          -- Raccourcis dans le chat
          send = { modes = { n = "<CR>", i = "<C-CR>" } },
          close = { modes = { n = "q", i = "<C-c>" } },
        },
      },
      inline = {
        adapter = "ollama",
      },
    },

    opts = {
      log_level = "ERROR",
    },
  },

  config = function(_, opts)
    require("codecompanion").setup(opts)

    -- Liste des modèles OpenRouter gratuits
    local openrouter_models = {
      "deepseek/deepseek-chat-v3-0324:free",
      "meta-llama/llama-4-maverick:free",
      "qwen/qwen3-235b-a22b:free",
      "google/gemma-3-27b-it:free",
      "microsoft/phi-4-reasoning:free",
      "nvidia/llama-3.1-nemotron-ultra-253b-v1:free",
    }

    -- Commande : Choisir modèle OpenRouter
    vim.api.nvim_create_user_command("IASelectOpenRouter", function()
      vim.ui.select(openrouter_models, {
        prompt = "🌐 Modèle OpenRouter :",
      }, function(choice)
        if choice then
          vim.notify("🌐 OpenRouter : " .. choice, vim.log.levels.INFO)
          vim.cmd("CodeCompanionChat openrouter")
          vim.defer_fn(function()
            vim.api.nvim_feedkeys("/model " .. choice .. "\n", "n", false)
          end, 500)
        end
      end)
    end, {})

    -- Commande : Choisir modèle Ollama
    vim.api.nvim_create_user_command("IASelectOllama", function()
      local handle = io.popen("ollama list 2>/dev/null | awk 'NR>1 {print $1}'")
      if not handle then
        vim.notify("❌ Ollama pas trouvé", vim.log.levels.ERROR)
        return
      end
      local result = handle:read("*a")
      handle:close()
      local models = vim.split(result, "\n", { trimempty = true })
      if #models == 0 then
        vim.notify("❌ Aucun modèle Ollama trouvé (lance 'ollama pull qwen3')", vim.log.levels.WARN)
        return
      end
      vim.ui.select(models, {
        prompt = "🦙 Modèle Ollama :",
      }, function(choice)
        if choice then
          vim.notify("🦙 Ollama : " .. choice, vim.log.levels.INFO)
          vim.cmd("CodeCompanionChat ollama")
          vim.defer_fn(function()
            vim.api.nvim_feedkeys("/model " .. choice .. "\n", "n", false)
          end, 500)
        end
      end)
    end, {})

    -- Commande : Lister les sessions chat ouvertes
    vim.api.nvim_create_user_command("IAListChats", function()
      local chats = {}
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        local ft = vim.bo[buf].filetype
        if ft == "codecompanion" then
          local name = vim.fn.bufname(buf):gsub(".*[/\\]", "")
          table.insert(chats, string.format("Buf %d: %s", buf, name))
        end
      end
      if #chats == 0 then
        vim.notify("Aucun chat ouvert", vim.log.levels.INFO)
      else
        vim.notify("Chats :\n" .. table.concat(chats, "\n"), vim.log.levels.INFO)
      end
    end, {})
  end,

  keys = {
    { "<leader>co", "<cmd>CodeCompanionChat ollama<cr>", desc = "Chat Ollama" },
    { "<leader>cr", "<cmd>CodeCompanionChat openrouter<cr>", desc = "Chat OpenRouter" },
    { "<leader>ca", "<cmd>CodeCompanionActions<cr>", desc = "Actions IA" },
    { "<leader>cz", "<cmd>IASelectOllama<cr>", desc = "Modèle Ollama" },
    { "<leader>cn", "<cmd>IASelectOpenRouter<cr>", desc = "Modèle OpenRouter" },
  },
}
