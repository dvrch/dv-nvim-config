
-- ~/.config/nvim/lua/plugins/custom-project-rule.lua
return {
  "ahmedkhalf/project.nvim",
  config = function()
    require("project_nvim").setup({
      -- Your existing configuration for project.nvim
      detection_methods = { "lsp", "pattern" }, -- Add "pattern" to detection methods
      patterns = { ".git", "Makefile", ".project" }, -- Add ".project" to patterns
    })
  end,
}
