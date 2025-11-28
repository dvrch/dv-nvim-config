
-- ~/.config/nvim/lua/plugins/telescope-frecency.lua
return {
  "nvim-telescope/telescope-frecency.nvim",
  -- Ce plugin a besoin d'une base de données et de telescope lui-même
  dependencies = { "nvim-telescope/telescope.nvim", "kkharji/sqlite.lua" },
  config = function()
    -- On charge l'extension pour la rendre disponible dans Telescope
    require("telescope").load_extension("frecency")
  end,
}
