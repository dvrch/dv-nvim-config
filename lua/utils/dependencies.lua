local function ensure_treesitter_installed()
  local parsers = { "markdown", "markdown_inline", "mermaid" }
  for _, parser in ipairs(parsers) do
    if not require("nvim-treesitter.parsers").has_parser(parser) then
      vim.cmd("TSInstall " .. parser)
    end
  end
end

local function ensure_system_deps()
  -- Vérifier si python3 est installé
  if vim.fn.executable("python3") == 0 then
    vim.notify("Installation de python3...", vim.log.levels.INFO)
    vim.fn.system("sudo apt-get update && sudo apt-get install -y python3 python3-pip")
    vim.fn.system("pip3 install --user pybtex")
  end

  -- Vérifier le chemin de mermaid-cli dans mason
  local mason_bin = vim.fn.expand("$HOME/.local/share/nvim/mason/bin/mmdc")
  if vim.fn.filereadable(mason_bin) == 0 then
    vim.notify("Installation de mermaid-cli via mason...", vim.log.levels.INFO)
    vim.cmd("MasonInstall mermaid-cli")
  end
end

return {
  ensure_all = function()
    ensure_treesitter_installed()
    ensure_system_deps()
  end
}