return {
  -- Configuration pour Svelte
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    opts = {
      ensure_installed = { "html", "css", "javascript", "typescript", "svelte" },
      highlight = {
        enable = true,
      },
      indent = { enable = true },
    },
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "mason-org/mason.nvim",
      "mason-org/mason-lspconfig.nvim",
    },
    opts = {
      ensure_installed = { "svelte", "tsserver" },
      setup = {
        svelte = function()
          require("lspconfig").svelte.setup({})
        end,
      },
    },
  },
  {
    "evanleck/nvim-svelte",
    ft = "svelte",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "neovim/nvim-lspconfig",
    },
    opts = {
      -- Vos options de configuration svelte.nvim ici
      -- Par exemple:
      -- lsp = {
      --   enabled = true,
      --   auto_install = true,
      -- },
    },
  },
}
