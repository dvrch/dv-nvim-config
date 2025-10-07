local M = {}

local function ensure_treesitter_installed()
  -- Attendre que treesitter soit chargé
  local ok, _ = pcall(require, "nvim-treesitter")
  if not ok then
    vim.notify("Treesitter non disponible", vim.log.levels.WARN)
    return
  end
  
  vim.cmd("TSInstall markdown markdown_inline mermaid")
end

local function ensure_system_deps()
  -- Installation de mermaid-cli via npm
  local mmdc = vim.fn.executable("mmdc") == 1
  if not mmdc then
    vim.notify("Installation de mermaid-cli via npm...", vim.log.levels.INFO)
    vim.fn.system("sudo npm install -g @mermaid-js/mermaid-cli")
  end

  -- Installation de python3
  if vim.fn.executable("python3") == 0 then
    vim.notify("Installation de python3...", vim.log.levels.INFO)
    vim.fn.system("sudo apt-get update && sudo apt-get install -y python3 python3-pip")
    vim.fn.system("pip3 install --user pybtex")
  end
end

M.ensure_all = function()
  vim.schedule(function()
    ensure_system_deps()
    ensure_treesitter_installed()
  end)
end

return M