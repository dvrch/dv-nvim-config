return {
  -- Ajoute le plugin gruvbox
  {
    "ellisonleao/gruvbox.nvim",
    opts = {
      transparent_mode = true,
      -- palette_overrides = {
        -- fg1 = "#b5b5a5",
      --},
    },
  },

  -- Configure LazyVim pour utiliser gruvbox par défaut
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "gruvbox",
    },
  },
}