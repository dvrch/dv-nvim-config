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
        ollama = "ollama",
        copilot = "copilot",
        mistral = "mistral",
        vibe = function()
          return require("codecompanion.adapters").extend("openai_compatible", {
            name = "vibe",
            formatted_name = "Vibe Mistral",
            env = {
              url = os.getenv("VIBE_URL") or "http://localhost:1234",
              api_key = os.getenv("VIBE_API_KEY") or "not-needed",
              chat_url = "/v1/chat/completions",
              models_endpoint = "/v1/models",
            },
            schema = {
              model = {
                default = "mistral",
              },
            },
          })
        end,
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
          layout = "vertical",
          width = 0.3,
        },
      },
      agent = {
        window = {
          layout = "vertical",
          width = 0.3,
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

    local function list_chats()
      local chats = {}
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        local name = vim.api.nvim_buf_get_name(buf)
        local ft = vim.api.nvim_buf_get_option(buf, "filetype")
        if ft == "codecompanion" then
          local adapter = vim.b[buf].codecompanion_adapter
          local label = adapter and adapter.formatted_name or "?"
          table.insert(chats, { buf = buf, name = name, label = label })
        end
      end
      if #chats == 0 then
        vim.notify("Aucun chat ouvert", vim.log.levels.INFO)
        return
      end
      local items = {}
      for _, c in ipairs(chats) do
        local active = vim.api.nvim_get_current_buf() == c.buf and ">" or " "
        table.insert(items, string.format("%s %s [%s]", active, c.label, vim.fn.fnamemodify(c.name, ":t")))
      end
      vim.ui.select(items, { prompt = "Chats ouverts :" }, function(_, idx)
        if idx then
          vim.api.nvim_set_current_buf(chats[idx].buf)
        end
      end)
    end

    vim.api.nvim_create_user_command("CodeCompanionChatList", list_chats, {})
  end,

  keys = {
    { "<leader>cr", "<cmd>CodeCompanionChat openrouter<cr>", desc = "Chat OpenRouter" },
    { "<leader>co", "<cmd>CodeCompanionChat ollama<cr>", desc = "Chat Ollama (local)" },
    { "<leader>cc", "<cmd>CodeCompanionChat copilot<cr>", desc = "Chat Copilot" },
    { "<leader>cm", "<cmd>CodeCompanionChat mistral<cr>", desc = "Chat Mistral" },
    { "<leader>cv", "<cmd>CodeCompanionChat vibe<cr>", desc = "Chat Vibe Mistral (local)" },
    { "<leader>ci", "<cmd>CodeCompanionInline<cr>", desc = "Inline IA", mode = { "n", "v" } },
    { "<leader>ca", "<cmd>CodeCompanionActions<cr>", desc = "Actions IA" },
    { "<leader>cg", "<cmd>CodeCompanionAgent<cr>", desc = "Agent IA" },
    { "<leader>cl", "<cmd>CodeCompanionChatList<cr>", desc = "Liste des chats" },
    { "<leader>aa", "<cmd>CodeCompanionActions<cr>", desc = "Actions IA", mode = { "n", "v" } },
  },
}
