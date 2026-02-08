return {
  -- 📦 LSP Configuration for Multiple Languages
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "mason-org/mason.nvim", -- Updated organization
      "mason-org/mason-lspconfig.nvim", -- Updated organization
    },
    opts = {
      -- Ensure these servers are installed automatically
      servers = {
        -- Python (With Houdini in mind)
        pyright = {
          settings = {
            python = {
              analysis = {
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
                diagnosticMode = "workspace",
              },
            },
          },
        },
        clangd = {},
        lua_ls = {
          settings = {
            Lua = {
              diagnostics = { globals = { "vim" } },
              workspace = { checkThirdParty = false },
            },
          },
        },
        marksman = {},
        svelte = {},
        ts_ls = {},
        html = {},
        cssls = {},
      },
    },
  },

  -- 💅 Formatting (Modern replacement for none-ls)
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        python = { "black" },
        lua = { "stylua" },
        svelte = { "prettier" },
        javascript = { "prettier" },
        html = { "prettier" },
        css = { "prettier" },
        markdown = { "prettier" },
      },
    },
  },

  -- 🧩 Linting (Modern replacement for none-ls)
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        python = { "flake8" },
      },
    },
  },
}
