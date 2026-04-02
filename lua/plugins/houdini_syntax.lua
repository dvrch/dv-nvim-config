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
          
          -- Activer l'autocomplétion native par syntaxe
          if vim.bo.filetype == "vex" then
            vim.bo.omnifunc = "syntaxcomplete#Complete"
          end
        end,
      })

    end,
  },
  
  -- 🚀 AUTOMATISATION DE L'AUTOCOMPLÉTION VEX
  {
    "hrsh7th/nvim-cmp",
    dependencies = { "hrsh7th/cmp-omni" },
    opts = function(_, opts)
      -- Ajoute la source Omni (pour VEX syntax) automatiquement aux suggestions
      local cmp = require("cmp")
      opts.sources = cmp.config.sources(vim.list_extend(opts.sources or {}, {
        { name = "omni" },
      }))
    end,
  },
}
