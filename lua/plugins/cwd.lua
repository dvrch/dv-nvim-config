return {
  {
    -- Priorité élevée pour s'assurer qu'il s'exécute avant les plugins de détection de racine
    priority = 1000,
    -- Charger ce plugin immédiatement au démarrage, ne pas le charger paresseusement
    lazy = false,
    config = function()
      -- Si Neovim a été ouvert avec un argument qui est un répertoire
      local arg = vim.fn.argv()[1]
      if vim.fn.argc() > 0 and arg and vim.fn.isdirectory(arg) == 1 then
        -- Alors, on change le répertoire de travail pour cet argument
        vim.cmd("silent! cd " .. vim.fn.argv()[1])
      end
    end,
  },
}