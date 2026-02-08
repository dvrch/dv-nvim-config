return {
  -- LSP Configuration for rust_analyzer
  {
    "neovim/nvim-lspconfig",
    ---@class LspConfigOpts
    opts = {
      servers = {
        rust_analyzer = {},
      },
      -- Custom setup for rust_analyzer to integrate with rust-tools.nvim
      setup = {
        rust_analyzer = function(_, opts)
          require("rust-tools").setup({ server = opts })
          return true
        end,
      },
    },
  },

  -- rust-tools.nvim for enhanced Rust development experience
  {
    "mrcjkb/rust-tools.nvim",
    ft = "rust", -- Only load for Rust files
    dependencies = {
      "neovim/nvim-lspconfig",
      "nvim-dap", -- Dependency for debugging
    },
    opts = function()
      return require("lazyvim.util").merge({
        server = {
          -- Options passed directly to rust_analyzer
          settings = {
            ["rust-analyzer"] = {
              inlayHints = {
                enable = true, -- Enable inlay hints (e.g., type hints, parameter names)
              },
              checkOnSave = {
                command = "clippy", -- Use clippy for checks on save
              },
            },
          },
        },
        dap = {
          adapter = {
            type = "executable",
            command = "codelldb",
            name = "rt_codelldb",
          },
        },
      }, require("lazyvim.config").get_kind_filter())
    end,
    config = function(_, opts)
      require("rust-tools").setup(opts)
    end,
  },

  -- Debugger (DAP) configuration for CodeLLDB
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "williamboman/mason.nvim",
      "jay-babu/mason-nvim-dap.nvim",
    },
    opts = function(_, opts)
      -- Ensure codelldb is installed via Mason
      require("mason-nvim-dap").setup({
        ensure_installed = { "codelldb" },
      })

      -- Configure codelldb adapter
      local dap = require("dap")
      dap.adapters.codelldb = {
        type = "server",
        host = "127.0.0.1",
        port = "${port}",
        executable = {
          command = "codelldb",
          args = { "--port", "${port}" },
          -- If codelldb is not in your PATH, you might need to specify its full path, e.g.:
          -- command = vim.fn.stdpath("data") .. "/mason/bin/codelldb",
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
          stopOnEntry = true,
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
          stopOnEntry = true,
        },
      }
    end,
  },

  -- nvim-treesitter for Rust syntax highlighting and parsing
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "rust", -- Ensure Rust parser is installed
      },
    },
  },
}
