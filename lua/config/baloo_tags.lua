local M = {}

-- Nom de l'attribut étendu utilisé par KDE pour les tags
local TAG_ATTR = "user.xdg.tags"

-- Fonction pour récupérer les tags actuels d'un fichier/dossier
local function get_tags(path)
  local cmd = string.format("getfattr --only-values -n %s %s 2>/dev/null", vim.fn.shellescape(TAG_ATTR), vim.fn.shellescape(path))
  local handle = io.popen(cmd)
  local result = handle:read("*a")
  handle:close()
  -- Nettoyage du résultat (enlever les guillemets et retours à la ligne)
  return result:gsub('^"', ''):gsub('"$', ''):gsub('[\n\r]', '')
end

-- Fonction pour appliquer des tags et forcer l'indexation Baloo
local function set_tags(path, tags_str)
  -- 1. Appliquer l'attribut étendu
  local cmd = string.format("setfattr -n %s -v %s %s", vim.fn.shellescape(TAG_ATTR), vim.fn.shellescape(tags_str), vim.fn.shellescape(path))
  vim.fn.system(cmd)
  
  -- 2. Forcer l'indexation immédiate par Baloo
  vim.fn.system(string.format("balooctl6 index %s", vim.fn.shellescape(path)))
  
  vim.notify(string.format("🏷️ Tags mis à jour pour : %s\n✨ Tags : %s", vim.fn.fnamemodify(path, ":t"), tags_str), vim.log.levels.INFO)
  
  -- 3. Si un Telescope est ouvert (recherche Baloo), on le rafraîchit
  local ok, telescope = pcall(require, "telescope.actions.state")
  if ok then
    local picker = telescope.get_current_picker(vim.api.nvim_get_current_buf())
    if picker then
        picker:refresh()
    end
  end
end

-- Interface utilisateur pour ajouter un tag au fichier courant ou au dossier
function M.tag_current_item()
  -- Détecter si on est dans l'explorateur (Neo-tree ou Oil) ou sur un buffer
  local path = vim.api.nvim_buf_get_name(0)
  
  -- Si c'est un buffer terminal ou vide, on ignore
  if path == "" or path:match("term://") then
    vim.notify("❌ Impossible de taguer cet élément.", vim.log.levels.WARN)
    return
  end

  local current_tags = get_tags(path)
  
  vim.ui.input({
    prompt = "🏷️ Modifier les tags (séparés par des virgules) : ",
    default = current_tags,
  }, function(input)
    if input then
      set_tags(path, input)
    end
  end)
end

-- Fonction pour taguer les fichiers sélectionnés dans Neo-tree (si utilisé)
function M.tag_neotree_selection()
  local state = require("neo-tree.sources.manager").get_state("filesystem")
  local nodes = require("neo-tree.ui.renderer").get_focused_node(state)
  -- Note: Cette partie dépend de l'implémentation spécifique de Neo-tree mais 
  -- voici la logique pour l'élément sous le curseur.
  if nodes and nodes.path then
    local path = nodes.path
    local current_tags = get_tags(path)
    vim.ui.input({
      prompt = "🏷️ Tags pour [" .. nodes.name .. "] : ",
      default = current_tags,
    }, function(input)
      if input then
        set_tags(path, input)
      end
    end)
  end
end

return M
