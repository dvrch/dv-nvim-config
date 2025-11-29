return {
  "pieces-app/plugin_neovim",
  lazy = false,  -- Chargement immédiat
  priority = 1000, -- Haute priorité
  config = function()
    require("pieces").setup({
      -- Configuration optionnelle
      enable_cloud = true,
      -- Autres options si nécessaire
    })
  end,
}