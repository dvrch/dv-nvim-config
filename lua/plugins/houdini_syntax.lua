return {
  -- 🧬 Houdini & VEX Syntax Highlighting
  {
    "teitoku72/vim-houdini",
    lazy = false,
    config = function()
      -- Détection automatique des fichiers .vfl et .vex
      vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
        pattern = { "*.vfl", "*.vex" },
        callback = function()
          vim.bo.filetype = "vex"
        end,
      })
    end,
  },
}
