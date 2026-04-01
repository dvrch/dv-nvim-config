return {
  -- 🧬 Houdini & VEX Syntax Highlighting
  {
    "drichardson/vim-vex",
    lazy = false,
    config = function()
      -- Détection automatique des fichiers VEX
      vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
        pattern = { "*.vfl", "*.vex" },
        callback = function()
          vim.bo.filetype = "vex"
        end,
      })
    end,
  },
}
