local function ensure_treesitter_installed()
  local parsers = { "markdown", "markdown_inline", "mermaid" }
  local ts_configs = require("nvim-treesitter.configs")
  
  ts_configs.setup({
    ensure_installed = parsers,
    sync_install = false,
    highlight = { enable = true },
  })
end

local function ensure_system_deps()
  -- Installation de mermaid-cli via npm si mason échoue
  local mason_bin = vim.fn.expand("$HOME/.local/share/nvim/mason/bin/mmdc")
  if vim.fn.filereadable(mason_bin) == 0 then
    vim.notify("Installation de mermaid-cli via npm...", vim.log.levels.INFO)
    vim.fn.system("sudo npm install -g @mermaid-js/mermaid-cli")
  end

  -- Vérifier python3
  if vim.fn.executable("python3") == 0 then
    vim.notify("Installation de python3...", vim.log.levels.INFO)
    vim.fn.system("sudo apt-get update && sudo apt-get install -y python3 python3-pip")
    vim.fn.system("pip3 install --user pybtex")
  end
end

return {
  ensure_all = function()
    vim.schedule(function()
      ensure_treesitter_installed()
      ensure_system_deps()
    end)
  end
}