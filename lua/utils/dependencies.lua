local M = {}

function M.ensure_all()
  vim.schedule(function()
    local mason_ok, mason = pcall(require, "mason-registry")
    if not mason_ok then
      vim.notify("Mason n'est pas disponible.", vim.log.levels.WARN)
      return
    end

    local mmdc = mason:get_package("mmdc")
    if not mmdc:is_installed() then
      vim.notify("Installation de mmdc (pour Mermaid)...", vim.log.levels.INFO)
      mmdc:install() 
    end
  end)
end

return M
