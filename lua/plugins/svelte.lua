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

}
