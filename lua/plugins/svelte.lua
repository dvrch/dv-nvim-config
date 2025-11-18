-- ~/.config/nvim/lua/plugins/svelte.lua
return {
  -- Ensure nvim-treesitter is configured for svelte
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate", -- Ensure parsers are updated
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, { "svelte" })
      end
    end,
  },

  -- Configure LSP for Svelte via nvim-lspconfig and mason-lspconfig
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "mason-org/mason.nvim",
      "mason-org/mason-lspconfig.nvim",
    },
    opts = {
      servers = {
        -- Ensure svelte-language-server is set up
        svelte = {},
      },
    },
    config = function(_, opts)
      require("mason").setup(opts.mason or {})
      require("mason-lspconfig").setup(opts.mason_lspconfig or {})
      require("lspconfig").svelte.setup(opts.servers.svelte)
    end,
  },
}
