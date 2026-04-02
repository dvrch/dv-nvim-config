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
      -- Sauvegarde Automatique ULTRA-LIVE (Caractère par caractère)
      vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI", "FocusLost", "BufLeave" }, {
        pattern = "/tmp/houdini_nvim/*",
        callback = function()
          if vim.bo.modified then
            vim.cmd("silent! update")
          end
        end,
      })
      
      -- Vérifier les changements extérieurs (Houdini -> Neovim)
      vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI", "BufEnter" }, {
        pattern = "/tmp/houdini_nvim/*",
        callback = function()
          vim.cmd("checktime")
        end,
      })

    end,
  }
}
