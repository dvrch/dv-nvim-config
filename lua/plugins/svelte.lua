-- ~/.config/nvim/lua/plugins/svelte.lua
return {
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
