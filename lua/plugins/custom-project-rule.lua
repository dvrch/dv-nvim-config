
-- ~/.config/nvim/lua/plugins/custom-project-rule.lua
return {
  "ahmedkhalf/project.nvim",
  opts = function(_, opts)
    -- Ajoute la détection d'un fichier .project à la liste des méthodes
    table.insert(opts.detection_methods, "pattern")
    vim.list_extend(opts.patterns, { ".project" })
  end,
}
