vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "text" },
  callback = function()
    vim.defer_fn(function()
      
      -- Define highlight groups based on Obsidian plugin colors
      vim.api.nvim_set_hl(0, "ObsidianComment", { fg = "#39FF14" })
      vim.api.nvim_set_hl(0, "ObsidianNumber", { fg = "#DA70D6" })
      vim.api.nvim_set_hl(0, "ObsidianOperator", { fg = "#FF4136" })
      vim.api.nvim_set_hl(0, "ObsidianPunctuation", { fg = "#00BFFF" })
      vim.api.nvim_set_hl(0, "ObsidianClassName", { fg = "#00FFFF" })
      vim.api.nvim_set_hl(0, "ObsidianFunctionCall", { fg = "#7FFF00" })
      vim.api.nvim_set_hl(0, "ObsidianSentenceCaps", { fg = "#9f8a13ff" })
      vim.api.nvim_set_hl(0, "ObsidianCapitalLetters", { fg = "#FF69B4" })
      vim.api.nvim_set_hl(0, "ObsidianDelimiterOpen", { fg = "#b35a01ff" })
      vim.api.nvim_set_hl(0, "ObsidianDelimiterClose", { fg = "#FF4500" })
      vim.api.nvim_set_hl(0, "ObsidianKeyword", { fg = "#FF00FF" })
      vim.api.nvim_set_hl(0, "ObsidianTagPattern", { fg = "#FFFF00" })
      vim.api.nvim_set_hl(0, "ObsidianDatePattern", { fg = "#ADFF2F" })
      vim.api.nvim_set_hl(0, "ObsidianString", { fg = "#a50f5fff" })
      vim.api.nvim_set_hl(0, "ObsidianParens", { fg = "#FF851B" })
      
      -- Apply syntax matches in order of priority
      -- Dans Vim, l'ordre de définition détermine la priorité (les derniers définis ont priorité)
      
      -- 1. Éléments de base (faible priorité)
      vim.cmd([[syntax match ObsidianCapitalLetters /[A-Z]/]])
      vim.cmd([[syntax match ObsidianDelimiterOpen /[({[<]/]])
      vim.cmd([[syntax match ObsidianDelimiterClose /[)}\]>]/]])
      vim.cmd([[syntax match ObsidianPunctuation /[.,;:?!]/]])
      vim.cmd([[syntax match ObsidianOperator /[-+*/%=<>!&|^~]/]])
      
      -- 2. Nombres (priorité moyenne-faible)
      vim.cmd([[syntax match ObsidianNumber /\<\d\+\>/]])
      vim.cmd([[syntax match ObsidianNumber /\<\d\+\.\d\+\>/]])
      
      -- 3. Régions avec contenu (priorité moyenne)
      -- vim.cmd([[syntax region ObsidianString start=/"/ skip=/\\"/ end=/"/ contains=ObsidianCapitalLetters,ObsidianNumber]])
      -- vim.cmd([[syntax region ObsidianString start=/(/ skip=/\\"/ end=/)/ contains=ObsidianCapitalLetters,ObsidianNumber]])
      -- vim.cmd([[syntax region ObsidianString start=/[/ skip=/\\"/ end=/]/ contains=ObsidianCapitalLetters,ObsidianNumber]])
      -- Suppression de la règle pour les guillemets simples/apostrophes pour éviter les conflits avec "l'importance"
      
      -- 4. Mots-clés et fonctions (priorité moyenne-haute)
      vim.cmd([[syntax match ObsidianKeyword /\<\(and\|as\|assert\|def\|class\|if\|else\|for\|while\|return\|import\|from\|with\|try\|except\|in\|is\|not\|or\)\>/]])
      vim.cmd([[syntax match ObsidianClassName /\<class\s\+\w\+/]])
      vim.cmd([[syntax match ObsidianFunctionCall /\w\+\s*(/me=e-1]])
      
      -- 5. Majuscules en début de phrase (priorité haute)
      vim.cmd([[syntax match ObsidianSentenceCaps /\(^\|[.!?]\s\+\)[A-Z]/hs=e]])
      
      -- 6. Patterns spéciaux (priorité très haute)
      vim.cmd([[syntax match ObsidianDatePattern /\d\{4\}-\d\{2\}-\d\{2\}/]])
      vim.cmd([[syntax match ObsidianTagPattern /#\w\+/]])
      
      -- 7. Commentaires (priorité maximale)
      vim.cmd([[syntax match ObsidianComment /#.*$/]])
      
      -- Guillemets et underscores comme délimiteurs spéciaux
      vim.cmd([[syntax match ObsidianDelimiterOpen /"/ contained]])
      vim.cmd([[syntax match ObsidianDelimiterClose /"/ contained]])
      vim.cmd([[syntax match ObsidianDelimiterOpen /_/ contained]])
      vim.cmd([[syntax match ObsidianDelimiterClose /_/ contained]])
      
    end, 100)
  end,
})