return {
  {
    "simrat39/rust-tools.nvim",
    dependencies = {
      "neovim/nvim-lspconfig",
    },
    opts = function(_, opts)
      local rt = require("rust-tools")
      opts.tools = opts.tools or {}

      opts.server = opts.server or {}
      require("lazyvim.util").lsp.on_attach(function(client, buffer)
        if client.name == "rust_analyzer" then
          -- Hover actions
          vim.keymap.set("n", "<C-space>", rt.hover_actions.hover_actions, { buffer = buffer })
          -- Code action groups
          vim.keymap.set("n", "<Leader>a", rt.code_action_group.code_action_group, { buffer = buffer })
        end
      end)
    end,
    config = function(_, opts)
      require("rust-tools").setup(opts)
    end,
  },

  -- Debugger (DAP) configuration for CodeLLDB
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "mason-org/mason.nvim", -- Fixed organization name
      "jay-babu/mason-nvim-dap.nvim",
    },
    config = function() -- Changed from opts to config to avoid calling dap.setup()
      local dap = require("dap")
      
      -- Ensure codelldb is installed via Mason
      require("mason-nvim-dap").setup({
        ensure_installed = { "codelldb" },
      })

      -- Configure codelldb adapter
      dap.adapters.codelldb = {
        type = "server",
        host = "127.0.0.1",
        port = "${port}",
        executable = {
          command = "codelldb",
          args = { "--port", "${port}" },
        },
      }

      -- Configure Rust launch configurations for DAP
      dap.configurations.rust = {
        {
          name = "Launch file",
          type = "codelldb",
          request = "launch",
          program = function()
            return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/target/debug/", "file")
          end,
          cwd = "${workspaceFolder}",
          stopOnEntry = false,
        },
        {
          name = "Launch test",
          type = "codelldb",
          request = "launch",
          program = function()
            return vim.fn.input("Path to test executable: ", vim.fn.getcwd() .. "/target/debug/", "file")
          end,
          args = { "--test" },
          cwd = "${workspaceFolder}",
          stopOnEntry = false,
        },
      }
    end,
  },
}
