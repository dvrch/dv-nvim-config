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
    event = "VeryLazy",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      local mermaid_utils = require("utils.mermaid")
      vim.keymap.set("n", "<leader>mp", mermaid_utils.preview, { desc = "Aperçu du diagramme Mermaid" })
    end
  }
}