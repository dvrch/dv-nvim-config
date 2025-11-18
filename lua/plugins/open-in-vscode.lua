-- ~/.config/nvim/lua/plugins/open-in-vscode.lua

return {

  lazy = false, -- Nous voulons que le raccourci soit disponible immédiatement
  config = function()
    -- Crée un raccourci clavier pour le mode normal
    -- <leader>ov signifie "leader" suivi de "o" (open) puis "v" (vscode)
    vim.keymap.set("n", "<leader>ov", function()
      -- Récupère le chemin complet du fichier actuel
      local file_path = vim.fn.expand("%:p")

      -- Vérifie si un fichier est bien ouvert (et non un buffer vide)
      if file_path and file_path ~= "" then
        -- Construit la commande à exécuter
        -- Utilise vim.fn.jobstart pour une exécution asynchrone qui ne bloque pas Neovim
        local cmd = { "code", file_path }
        vim.fn.jobstart(cmd, { detach = true })

        -- Affiche une notification de confirmation
        vim.notify("Ouverture dans VSCode: " .. vim.fn.pathshorten(file_path), vim.log.levels.INFO)
      else
        -- Affiche un avertissement si aucun fichier n'est ouvert
        vim.notify("Aucun fichier à ouvrir dans VSCode.", vim.log.levels.WARN)
      end
    end, { desc = "Ouvrir le fichier actuel dans VSCode" })
  end,
}
