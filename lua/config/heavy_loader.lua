-- ~/.config/nvim/lua/config/heavy_loader.lua
-- Système de chargement différé pour les plugins lourds

local M = {}

local loaded = false

function M.trigger_heavy_load()
  if loaded then return end
  loaded = true
  
  -- Exécuter en arrière-plan sans bloquer l'UI
  vim.schedule(function()
    print("🚀 Déploiement des plugins lourds en arrière-plan...")
    vim.api.nvim_exec_autocmds("User", { pattern = "LoadHeavy" })
    print("✅ Plugins lourds (Pieces, Jupyter, Unreal, Houdini) chargés.")
  end)
end

function M.setup()
  -- Commande utilisateur pour forcer immédiatement le chargement 
  vim.api.nvim_create_user_command("LazyLoadHeavy", function()
    M.trigger_heavy_load()
  end, { desc = "Charger les plugins lourds manuellement" })

  -- Raccourci clavier (<leader>LH)
  vim.keymap.set("n", "<leader>LH", "<cmd>LazyLoadHeavy<cr>", { desc = "Load Heavy Plugins" })

  -- Chargement AUTOMATIQUE différé : Se déclenche 2 secondes (2000 ms) après le démarrage réussi
  vim.defer_fn(function()
    M.trigger_heavy_load()
  end, 2000)
end

return M

