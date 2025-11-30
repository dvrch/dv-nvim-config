-- ~/.config/nvim/lua/plugins/pieces.lua
return {
  -- Les dépendances doivent être installées séparément
  {
    "kyazdani42/nvim-web-devicons",
    lazy = true,
  },
  {
    "MunifTanjim/nui.nvim",
    lazy = true,
  },
  {
    "hrsh7th/nvim-cmp",
    lazy = true,
  },

  -- Plugin principal Pieces
  {
    "pieces-app/plugin_neovim",
    dependencies = {
      "kyazdani42/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
      "hrsh7th/nvim-cmp",
    },
    config = function()
      -- Le plugin se configure automatiquement
      vim.notify("Pieces plugin loaded - run :UpdateRemotePlugins")
    end,
    -- Important: ne pas lazy load pour l'initialisation
    lazy = false,
  },
}
