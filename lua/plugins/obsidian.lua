-- Fonction pour trouver et lister dynamiquement tous les coffres Obsidian
local function get_obsidian_vaults()
  -- Chemin vers le fichier de configuration principal d'Obsidian
  local obsidian_config_path = os.getenv("HOME") .. "/.config/obsidian/obsidian.json"

  -- Vérifier si le fichier existe
  local f = io.open(obsidian_config_path, "r")
  if not f then
    vim.notify("Config Obsidian non trouvée: " .. obsidian_config_path, vim.log.levels.WARN)
    return {} -- Retourne une table vide si le fichier n'existe pas
  end

  -- Lire le contenu du fichier
  local content = f:read("*a")
  f:close()

  -- Décoder le contenu JSON en toute sécurité
  local ok, data = pcall(vim.fn.json_decode, content)
  if not ok or type(data) ~= "table" or not data.vaults then
    vim.notify("Échec de l'analyse de la config Obsidian ou clé 'vaults' non trouvée.", vim.log.levels.ERROR)
    return {}
  end

  -- Extraire le chemin de chaque coffre
  local vaults = {}
  for _, vault_info in pairs(data.vaults) do
    if type(vault_info) == "table" and vault_info.path then
      table.insert(vaults, vault_info.path)
    end
  end

  vim.notify("obsidian.nvim: " .. #vaults .. " coffre(s) chargé(s).", vim.log.levels.INFO)
  return vaults
end

return {
  "epwalsh/obsidian.nvim",
  version = "*", -- recommandé
  lazy = true,
  ft = "markdown",

  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim",
  },

  -- Utiliser la fonction pour définir dynamiquement les répertoires des coffres
  opts = {
    dir = get_obsidian_vaults(),
    -- Vous pouvez ajouter d'autres options ici si nécessaire
  },

  -- Vos raccourcis clavier personnalisés (recommandé)
  keys = {
    { "<leader>oo", "<cmd>ObsidianOpen<CR>", desc = "Ouvrir dans Obsidian" },
    { "<leader>os", "<cmd>ObsidianSearch<CR>", desc = "Chercher une note" },
    { "<leader>on", "<cmd>ObsidianNew<CR>", desc = "Nouvelle note" },
  },
}