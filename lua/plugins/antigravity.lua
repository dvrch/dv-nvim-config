return {
  {
    -- Dépendances pour les keymaps CodeCompanion
    "olimorris/codecompanion.nvim",
    keys = {
      { "<leader>ia", function()
        vim.cmd("terminal agy")
        vim.cmd("startinsert")
      end, desc = "Terminal agy", mode = "n" },
    },
  },
}
