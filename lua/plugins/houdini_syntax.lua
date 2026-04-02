return {
  -- 🧬 Houdini & VEX Syntax Highlighting
  {
    "drichardson/vim-vex",
    lazy = false,
    config = function()
      -- Détection automatique des fichiers VEX et activation OmniCompletion
      vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
        pattern = { "*.vfl", "*.vex", "*houdini_temp*" },
        callback = function(args)
          local file = vim.api.nvim_buf_get_name(args.buf)
          if file:match("%.vfl$") or file:match("%.vex$") or file:match("houdini_temp") then
            -- Forcer syntaxe vex si c'est un temp python/vex indéterminé
            if not file:match("%.py$") then
              vim.bo.filetype = "vex"
            end
          end
          
          -- Activer l'autocomplétion native par syntaxe (Ctrl-X Ctrl-O)
          if vim.bo.filetype == "vex" then
            vim.bo.omnifunc = "syntaxcomplete#Complete"
          end
        end,
      })

    end,
  },
}
