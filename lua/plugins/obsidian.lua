-- Fonction pour trouver et lister dynamiquement tous les coffres Obsidian
local function get_obsidian_vaults()
  -- Chemin vers le fichier de configuration principal d'Obsidian
  local obsidian_config_path = os.getenv("HOME") .. "/.config/obsidian/obsidian.json"

  local f = io.open(obsidian_config_path, "r")
  if not f then
    return {}
  end

  local content = f:read("*a")
  f:close()

  local ok, data = pcall(vim.fn.json_decode, content)
  if not ok or type(data) ~= "table" or not data.vaults then
    return {}
  end

  -- Créer une liste de "spécifications de workspace" ({ path = "..." })
  local vaults = {}
  for _, vault_info in pairs(data.vaults) do
    if type(vault_info) == "table" and vault_info.path then
      -- CORRECTION : Insérer une table de spécification, pas juste une chaîne
      table.insert(vaults, { path = vault_info.path })
    end
  end

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

  opts = function()
    local vaults = get_obsidian_vaults()

    if #vaults == 0 then
      vim.notify("obsidian.nvim: Aucun coffre n'a été détecté.", vim.log.levels.WARN)
      return {}
    else
      vim.notify("obsidian.nvim: " .. #vaults .. " coffre(s) chargé(s).", vim.log.levels.INFO)
      return {
        -- L'option 'dir' est dépréciée en faveur de 'workspaces'
        workspaces = vaults,
        -- Vous pouvez ajouter d'autres options ici si nécessaire
      }
    end
  end,

  keys = {
    { "<leader>oo", "<cmd>ObsidianOpen<CR>", desc = "Ouvrir dans Obsidian" },
    { "<leader>os", "<cmd>ObsidianSearch<CR>", desc = "Chercher une note" },
    { "<leader>on", "<cmd>ObsidianNew<CR>", desc = "Nouvelle note" },
  },
}