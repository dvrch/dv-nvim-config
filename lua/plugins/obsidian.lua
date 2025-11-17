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
      table.insert(vaults, { path = vault_info.path })
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
    vim.cmd("ObsidianOpen")
  else
    local target_dir = "/home/kd/Bureau/fict_vlt/lzvimll"
    vim.fn.system(string.format("mkdir -p %s", vim.fn.shellescape(target_dir)))
    
    local symlink_cmd = string.format("ln -sf %s %s", vim.fn.shellescape(current_file), vim.fn.shellescape(target_dir))
    
    local result = vim.fn.system(symlink_cmd)
    if vim.v.shell_error ~= 0 then
      vim.notify("Échec de la création du lien symbolique: " .. result, vim.log.levels.ERROR)
    else
      vim.notify("Lien symbolique créé dans " .. target_dir, vim.log.levels.INFO)
      
      -- **LA CORRECTION EST ICI**
      -- Construire le chemin de la note relatif au coffre et l'ouvrir explicitement.
      local file_name = vim.fn.fnamemodify(current_file, ":t")
      local note_path_in_vault = "lzvimll/" .. file_name
      
      -- Exécuter ObsidianOpen avec le chemin de la note à ouvrir
      vim.cmd("ObsidianOpen " .. vim.fn.fnameescape(note_path_in_vault))
    end
  end
end

-- Création de la commande utilisateur
vim.api.nvim_create_user_command("ObsidianOpenOrLink", _G.ObsidianOpenOrLink, {})


-- [[ CONFIGURATION DU PLUGIN LAZYVIM ]]

return {
  "epwalsh/obsidian.nvim",
  version = "*",
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