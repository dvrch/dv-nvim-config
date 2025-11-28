return {
  {
    event = "VimEnter",
    config = function()
      -- Vérifie si Neovim a été ouvert avec un répertoire comme argument
      if vim.fn.argc() > 0 and vim.fn.isdirectory(vim.fn.argv()[1]) == 1 then
        -- Change le répertoire de travail pour celui spécifié
        vim.cmd("silent! cd " .. vim.fn.argv()[1])
      end
    end,
  },
}
