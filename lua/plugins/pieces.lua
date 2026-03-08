return {
  -- Pièces OS for Neovim (Plugin officiel)
  {
    "pieces-app/plugin_neovim",
    event = { "User LoadHeavy" },
    dependencies = {
      "MunifTanjim/nui.nvim",
      "hrsh7th/nvim-cmp",
    },

    opts = {
      -- Configuration de base si nécessaire
    },
    config = function()
      -- Keymaps spécifiques pour Pieces si besoin
      vim.keymap.set("n", "<leader>pa", "<cmd>PiecesConnect<cr>", { desc = "Pieces: Connect" })
      vim.keymap.set("n", "<leader>ps", "<cmd>PiecesSettings<cr>", { desc = "Pieces: Settings" })
    end,
  },
}
