return {
  name = "cwd-config", -- Add this line
  -- Exécuter avec une haute priorité au démarrage
  priority = 1000,
  lazy = false,
  event = "VeryLazy", -- Add this line to make it a valid local plugin spec
  config = function()
    -- Si Neovim a été ouvert avec un répertoire comme argument
    local arg = vim.fn.argv()[1]
    if vim.fn.argc() > 0 and arg and vim.fn.isdirectory(arg) == 1 then
      -- Attendre 10 millisecondes que tous les autres plugins aient fini leur initialisation
      vim.defer_fn(function()
        -- Forcer le changement de répertoire pour qu'il soit la commande finale
        vim.cmd("silent! cd " .. arg)
      end, 10)
    end
  end,
}

