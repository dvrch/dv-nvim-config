-- Variable globale pour l'état de la syntaxe personnalisée
vim.g.custom_syntax_enabled = true

-- Fonction pour activer/désactiver
function _G.toggle_custom_syntax()
  vim.g.custom_syntax_enabled = not vim.g.custom_syntax_enabled
  if vim.g.custom_syntax_enabled then
    vim.notify("Syntaxe Obsidienne ACTIVÉE", vim.log.levels.INFO)
    vim.cmd("doautocmd FileType") -- Déclenche la recharge pour markdown/text
  else
    vim.notify("Syntaxe Obsidienne DÉSACTIVÉE", vim.log.levels.WARN)
    vim.cmd("syntax clear") -- Nettoie la syntaxe actuelle
    -- On recharge le FileType natif après un court délai
    vim.defer_fn(function()
      vim.cmd("set filetype=" .. vim.bo.filetype)
    end, 50)
  end
end

-- Raccourci clavier (Toggle) : <leader>uy (User Syntax)
vim.keymap.set("n", "<leader>uy", _G.toggle_custom_syntax, { desc = "Toggle Custom Obsidian Syntax" })

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "text" },
  callback = function()
    -- Ne pas appliquer si désactivé ou si c'est un buffer de notebook géré par Quarto/Jupytext
    if not vim.g.custom_syntax_enabled or vim.bo.filetype == "quarto" or vim.fn.expand("%:e") == "ipynb" then
      return
    end

    vim.defer_fn(function()
      -- Define highlight groups based on Obsidian plugin colors
      local hls = {
        ObsidianComment = "#39FF14",
        ObsidianNumber = "#DA70D6",
        ObsidianOperator = "#FF4136",
        ObsidianPunctuation = "#00BFFF",
        ObsidianClassName = "#00FFFF",
        ObsidianFunctionCall = "#7FFF00",
        ObsidianSentenceCaps = "#9f8a13",
        ObsidianCapitalLetters = "#FF69B4",
        ObsidianDelimiterOpen = "#b35a01",
        ObsidianDelimiterClose = "#FF4500",
        ObsidianKeyword = "#FF00FF",
        ObsidianTagPattern = "#FFFF00",
        ObsidianDatePattern = "#ADFF2F",
        ObsidianString = "#a50f5f",
        ObsidianParens = "#FF851B",
      }
      for group, color in pairs(hls) do
        vim.api.nvim_set_hl(0, group, { fg = color })
      end

      -- Apply syntax matches
      vim.cmd([[syntax match ObsidianCapitalLetters /[A-Z]/]])
      vim.cmd([[syntax match ObsidianDelimiterOpen /[({[<]/]])
      vim.cmd([[syntax match ObsidianDelimiterClose /[)}\]>]/]])
      vim.cmd([[syntax match ObsidianPunctuation /[.,;:?!]/]])
      vim.cmd([[syntax match ObsidianOperator /[-+*/%=<>!&|^~]/]])
      vim.cmd([[syntax match ObsidianNumber /\<\d\+\>/]])
      vim.cmd([[syntax match ObsidianNumber /\<\d\+\.\d\+\>/]])
      vim.cmd([[syntax match ObsidianKeyword /\<\(and\|as\|assert\|def\|class\|if\|else\|for\|while\|return\|import\|from\|with\|try\|except\|in\|is\|not\|or\)\>/]])
      vim.cmd([[syntax match ObsidianClassName /\<class\s\+\w\+/]])
      vim.cmd([[syntax match ObsidianFunctionCall /\w\+\s*(/me=e-1]])
      vim.cmd([[syntax match ObsidianSentenceCaps /\(^\|[.!?]\s\+\)[A-Z]/hs=e]])
      vim.cmd([[syntax match ObsidianDatePattern /\d\{4\}-\d\{2\}-\d\{2\}/]])
      vim.cmd([[syntax match ObsidianTagPattern /#\w\+/]])
      vim.cmd([[syntax match ObsidianComment /#.*$/]])
    end, 100)
  end,
})
