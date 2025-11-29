return {
  "pieces-app/plugin_neovim",
  lazy = false,  -- Chargement immédiat
  priority = 1000, -- Haute priorité
  ft = { 'python', 'lua', 'vim', 'markdown' }, -- Add filetype detection
  dependencies = {
    'nvim-lua/plenary.nvim', -- Add plenary.nvim as a dependency
  },
  config = function()
    require("pieces").setup({
      -- Configuration optionnelle
      enable_cloud = true,
      -- Autres options si nécessaire
    })
  end,
}