return {
  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        { "<leader>m", name = "Mermaid" },
        { "<leader>z", name = "Zotero" },
      },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    opts = {
      sync_install = false,
      ensure_installed = {
        "bash",
        "markdown",
        "markdown_inline",
        "mermaid",
      },
    },
  },
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "mermaid-cli" })
    end,
  }
}