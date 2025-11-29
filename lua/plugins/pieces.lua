require("pieces.copilot")
require("pieces.assets")
require("pieces.copilot.slash_commands")
require("pieces.onboarding")
require("pieces.feedback")
require("pieces.tutor")

return {
  -- Dépendance obligatoire pour Pieces OS
  { "nvim-tree/nvim-web-devicons", lazy = true },
  -- Ton plugin Pieces OS (exemple)
  {
    "pieces-app/plugin_neovim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("pieces").setup()
    end,
    -- Autres options selon ton setup
  },
}
