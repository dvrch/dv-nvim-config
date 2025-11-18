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
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "mmdc" })
    end,
  }
}