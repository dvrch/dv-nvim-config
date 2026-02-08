return {
  -- 📦 LSP Configuration for Multiple Languages
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
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
        -- C++
        clangd = {},
        -- Lua (For Neovim config)
        lua_ls = {
          settings = {
            Lua = {
              diagnostics = { globals = { "vim" } },
              workspace = { checkThirdParty = false },
            },
          },
        },
        -- Markdown
        marksman = {},
        -- Svelte & Web
        svelte = {},
        ts_ls = {}, -- Replacement for tsserver
        html = {},
        cssls = {},
      },
    },
    config = function(_, opts)
      local lspconfig = require("lspconfig")
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      for server, server_opts in pairs(opts.servers) do
        server_opts.capabilities = capabilities
        lspconfig[server].setup(server_opts)
      end
    end,
  },

  -- 💅 Linting & Formatting (null-ls equivalent)
  {
    "nvimtools/none-ls.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local null_ls = require("null-ls")
      null_ls.setup({
        sources = {
          -- Python
          null_ls.builtins.formatting.black,
          null_ls.builtins.diagnostics.flake8,
          -- Markdown
          null_ls.builtins.formatting.prettier.with({
            filetypes = { "markdown", "html", "css", "svelte", "javascript" },
          }),
          -- Lua
          null_ls.builtins.formatting.stylua,
        },
      })
    end,
  },

  -- 🧩 Autocomp (cmp) integration
  {
    "hrsh7th/nvim-cmp",
    opts = function(_, opts)
      local cmp = require("cmp")
      opts.mapping = cmp.mapping.preset.insert({
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<CR>"] = cmp.mapping.confirm({ select = true }),
      })
      opts.sources = cmp.config.sources({
        { name = "nvim_lsp" },
        { name = "buffer" },
        { name = "path" },
      })
    end,
  },
}
