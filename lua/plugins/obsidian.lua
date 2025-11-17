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
  local is_in_vault = false
  for _, workspace in ipairs(vaults_config) do
    if is_path_inside(current_file, workspace.path) then
      is_in_vault = true
      break
    end
  end

  if is_in_vault then
    -- Le fichier est déjà dans un coffre. Le simple fait que le buffer soit
    -- ouvert signifie que le plugin a déjà basculé sur le bon coffre.
    vim.cmd("ObsidianOpen")
  else
    -- Fichier hors de tout coffre.
    local target_dir = "/home/kd/Bureau/fict_vlt/lzvimll"
    vim.fn.system(string.format("mkdir -p %s", vim.fn.shellescape(target_dir)))
    
    -- Copier le fichier
    local copy_cmd = string.format("cp %s %s", vim.fn.shellescape(current_file), vim.fn.shellescape(target_dir))
    vim.fn.system(copy_cmd)
    vim.notify("Fichier copié dans " .. target_dir, vim.log.levels.INFO)

    -- **LA LOGIQUE FINALE**
    -- 1. Ouvrir la copie dans un nouveau buffer.
    local file_name = vim.fn.fnamemodify(current_file, ":t")
    local copied_file_path = target_dir .. "/" .. file_name
    vim.cmd("edit " .. vim.fn.fnameescape(copied_file_path))

    -- 2. Laisser le temps à l'autocommand 'BufEnter' du plugin de s'exécuter.
    --    Cela va automatiquement basculer sur le bon coffre.
    vim.schedule(function()
      -- 3. Appeler ObsidianOpen, qui agira sur le nouveau buffer (la copie)
      --    et dans le bon coffre.
      vim.cmd("ObsidianOpen")
    end)
  end
end

-- Création de la commande utilisateur
vim.api.nvim_create_user_command("ObsidianOpenOrLink", _G.ObsidianOpenOrLink, {})


-- [[ CONFIGURATION DU PLUGIN LAZYVIM ]]

return {
  "epwalsh/obsidian.nvim",
  version = "*",
  -- lazy = true est de nouveau possible car on s'appuie sur les autocommands
  -- plutôt que sur l'API Lua au démarrage.
  lazy = true,
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
    { "<leader>oo", "<cmd>ObsidianOpenOrLink<CR>", desc = "Ouvrir ou Copier dans Obsidian" },
    { "<leader>os", "<cmd>ObsidianSearch<CR>", desc = "Chercher une note" },
    { "<leader>on", "<cmd>ObsidianNew<CR>", desc = "Nouvelle note" },
  },
}