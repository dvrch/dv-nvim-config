return {
  -- Pieces for Neovim Plugin
  {
    "pieces-app/plugin_neovim",
    dependencies = {
      "kyazdani42/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
      "hrsh7th/nvim-cmp",
    },
    config = function()
      -- Add any specific configuration here if needed.
      -- The plugin might "just work" without this function.
    end,
  },
}
