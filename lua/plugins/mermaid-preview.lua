return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, { "mermaid" })
      end
    end,
  },
  {
    "folke/which-key.nvim",
    optional = true,
    opts = {
      spec = {
        { "<leader>m", group = "Mermaid" },
      },
    },
  },
  {
    "nvim-lua/plenary.nvim", -- dependency for the preview function
    lazy = true,
  },
  {
    "akinsho/toggleterm.nvim", -- another dependency
    optional = true,
  },
  {
    "LazyVim/LazyVim",
    keys = {
        { "<leader>mp", function() require("utils.mermaid").preview() end, desc = "Aperçu du diagramme Mermaid" },
    },
  }
}
