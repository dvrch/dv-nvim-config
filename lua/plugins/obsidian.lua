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
    -- Le fichier est déjà dans un coffre. On l'ouvre.
    -- Le plugin bascule automatiquement de workspace grâce à son autocommand 'BufEnter'.
    vim.cmd("ObsidianOpen")
  else
    -- Fichier hors de tout coffre, on gère le lien symbolique.
    local vault_path = "/home/kd/Bureau/fict_vlt" -- Chemin racine du coffre Obsidian
    local symlink_subdir = "lzvimll" -- Sous-dossier pour les liens symboliques
    local target_dir = vault_path .. "/" .. symlink_subdir
    local vault_name = vim.fn.fnamemodify(vault_path, ":t") -- Nom du coffre (ex: "fict_vlt")

    local file_name = vim.fn.fnamemodify(current_file, ":t")
    local symlink_path_absolute = target_dir .. "/" .. file_name
    -- Le chemin pour l'URI doit être relatif à la racine du coffre
    local file_path_relative_to_vault = symlink_subdir .. "/" .. file_name

    -- S'assurer que le dossier cible existe et créer le lien
    if vim.fn.filereadable(symlink_path_absolute) == 0 then
      vim.fn.system(string.format("mkdir -p %s", vim.fn.shellescape(target_dir)))
      local symlink_cmd = string.format("ln -s %s %s", vim.fn.shellescape(current_file), vim.fn.shellescape(symlink_path_absolute))
      vim.fn.system(symlink_cmd)
      vim.notify("Lien symbolique créé : " .. symlink_path_absolute, vim.log.levels.INFO)
    end

    -- Construire l'URI avec le nom correct du coffre et le chemin relatif du fichier.
    local obsidian_uri = string.format("obsidian://open?vault=%s&file=%s",
      vim.fn.escape(vault_name, " "),
      vim.fn.escape(file_path_relative_to_vault, " ")
    )
    vim.fn.system(string.format("xdg-open %s", vim.fn.shellescape(obsidian_uri)))
    vim.notify("Ouverture via URI : " .. obsidian_uri, vim.log.levels.INFO)

    -- Basculer l'éditeur sur le lien pour la cohérence.
    vim.cmd("edit " .. vim.fn.fnameescape(symlink_path_absolute))
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
