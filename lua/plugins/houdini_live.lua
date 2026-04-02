return {
  -- 🛰️ HOUDINI LIVE SYNC CONFIGURATION
  {
    "LazyVim/LazyVim",
    opts = {
      -- On s'assure que Neovim recharge les fichiers modifiés par Houdini
      options = {
        autoread = true,
        autowriteall = true,
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      -- Autocommande pour Sauvegarde Automatique et Relecture
      vim.api.nvim_create_autocmd({ "FocusLost", "BufLeave", "TermLeave" }, {
        pattern = "/tmp/houdini_nvim/*",
        callback = function()
          if vim.bo.modified then
            vim.cmd("silent! wall")
          end
        end,
      })
      
      -- Vérifier les changements extérieurs toutes les secondes (Houdini -> Neovim)
      vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
        pattern = "/tmp/houdini_nvim/*",
        callback = function()
          vim.cmd("checktime")
        end,
      })
    end,
  }
}
