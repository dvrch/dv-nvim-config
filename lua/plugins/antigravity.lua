return {
  {
    "olimorris/codecompanion.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "hrsh7th/nvim-cmp", -- Optional: For autocompletion
      "nvim-telescope/telescope.nvim", -- Optional: For searching and picking
      { "stevearc/dressing.nvim", opts = {} }, -- Optional: Better UI
    },
    config = function()
      require("codecompanion").setup({
        strategies = {
          chat = {
            adapter = "openai", -- or "anthropic", "gemini" etc.
          },
          inline = {
            adapter = "openai",
          },
          agent = {
            adapter = "openai",
          },
        },
      })
      
      -- Add keymaps
      vim.keymap.set({ "n", "v" }, "<leader>aa", "<cmd>CodeCompanionActions<cr>", { desc = "Antigravity Actions" })
      vim.keymap.set({ "n", "v" }, "<leader>ac", "<cmd>CodeCompanionChat<cr>", { desc = "Antigravity Chat" })
      vim.keymap.set("v", "ga", "<cmd>CodeCompanionChat Add<cr>", { desc = "Add to Antigravity Chat" })
    end,
  },
}
