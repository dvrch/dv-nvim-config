-- [[ GESTION AMÉLIORÉE POUR OBSIDIAN ]]

-- Helper pour vérifier si un fichier est dans un dossier
local function is_path_inside(file_path, dir_path)
  local abs_file = vim.fn.fnamemodify(file_path, ":p")
  local abs_dir = vim.fn.fnamemodify(dir_path, ":p")
  if string.sub(abs_dir, -1) ~= "/" then
    abs_dir = abs_dir .. "/"
  end
  return string.sub(abs_file, 1, #abs_dir) == abs_dir
end

-- Fonction pour trouver et lister dynamiquement tous les coffres Obsidian
local function get_obsidian_vaults()
  local obsidian_config_path = os.getenv("HOME") .. "/.config/obsidian/obsidian.json"
  local f = io.open(obsidian_config_path, "r")
  if not f then return {} end
  local content = f:read("*a")
  f:close()
  local ok, data = pcall(vim.fn.json_decode, content)
  if not ok or type(data) ~= "table" or not data.vaults then return {} end

  local vaults = {}
  for _, vault_info in pairs(data.vaults) do
    if type(vault_info) == "table" and vault_info.path then
      table.insert(vaults, { path = vault_info.path, name = vim.fn.fnamemodify(vault_info.path, ":t") })
    end
  end
  return vaults
end

-- Fonction principale pour la commande personnalisée
function _G.ObsidianOpenOrLink()
  local current_file = vim.fn.expand('%:p')
  if not current_file or current_file == "" then
    vim.notify("Aucun fichier à ouvrir.", vim.log.levels.WARN)
    return
  end

  local vaults_config = get_obsidian_vaults()
  local target_vault = nil
  local file_to_open = current_file

  -- Déterminer le coffre cible
  for _, vault in ipairs(vaults_config) do
    if is_path_inside(current_file, vault.path) then
      target_vault = vault
      break
    end
  end

  -- Si hors de tout coffre, utiliser la logique du lien symbolique
  if not target_vault then
    local symlink_vault_path = "/home/kd/Bureau/fict_vlt"
    for _, vault in ipairs(vaults_config) do
      if vault.path == symlink_vault_path then
        target_vault = vault
        break
      end
    end

    if not target_vault then
      vim.notify("Le coffre pour les liens symboliques n'a pas été trouvé.", vim.log.levels.ERROR)
      return
    end

    local target_dir = target_vault.path .. "/lzvimll"
    vim.fn.system(string.format("mkdir -p %s", vim.fn.shellescape(target_dir)))
    local symlink_cmd = string.format("ln -sf %s %s", vim.fn.shellescape(current_file), vim.fn.shellescape(target_dir))
    vim.fn.system(symlink_cmd)
    
    local file_name = vim.fn.fnamemodify(current_file, ":t")
    file_to_open = target_dir .. "/" .. file_name
    vim.notify("Lien symbolique créé pour " .. file_name, vim.log.levels.INFO)
  end

  -- Logique de changement de coffre et d'ouverture
  local client = require("obsidian").util.get_client()
  local current_workspace_path = client.workspace.path

  local function open_note()
    vim.schedule(function()
      vim.cmd("ObsidianOpen " .. vim.fn.fnameescape(file_to_open))
    end)
  end

  if current_workspace_path ~= target_vault.path then
    vim.notify("Changement de coffre vers: " .. target_vault.name, vim.log.levels.INFO)
    -- Le changement de workspace est asynchrone et prend un callback
    client:switch_workspace(target_vault.name, open_note)
  else
    -- Déjà dans le bon coffre, ouvrir directement
    open_note()
  end
end

-- Création de la commande utilisateur
vim.api.nvim_create_user_command("ObsidianOpenOrLink", _G.ObsidianOpenOrLink, {})


-- [[ CONFIGURATION DU PLUGIN LAZYVIM ]]

return {
  "epwalsh/obsidian.nvim",
  version = "*",
  lazy = false, -- Mettre à false pour que le client soit toujours dispo
  ft = "markdown",

  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim",
  },

  opts = function()
    local vaults = get_obsidian_vaults()
    if #vaults == 0 then
      return {}
    else
      return {
        workspaces = vaults,
      }
    end
  end,

  keys = {
    { "<leader>oo", "<cmd>ObsidianOpenOrLink<CR>", desc = "Ouvrir ou Lier dans Obsidian" },
    { "<leader>os", "<cmd>ObsidianSearch<CR>", desc = "Chercher une note" },
    { "<leader>on", "<cmd>ObsidianNew<CR>", desc = "Nouvelle note" },
  },
}
