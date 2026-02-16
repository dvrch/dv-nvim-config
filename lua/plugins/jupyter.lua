return {
  -- Molten: Configuration Professionnelle (Type VSCode)
  {
    "benlubas/molten-nvim",
    version = "^1.0.0",
    build = ":UpdateRemotePlugins",
    init = function()
      -- CONFIGURATION AFFICHAGE (Identique à VSCode)
      vim.g.molten_auto_open_output = true -- Ouvre le float si nécessaire
      vim.g.molten_virt_text_output = true -- Affiche le résultat SOUS la ligne ✅
      vim.g.molten_virt_lines_off_by_1 = false -- Pile sous la ligne
      vim.g.molten_output_win_max_height = 20
      vim.g.molten_wrap_output = true
      vim.g.molten_image_provider = "image.nvim"
      
      -- FONCTION DE SECOURS : Exécuter une plage (Utilisée pour les cellules)
      _G.molten_run_range = function(start_l, end_l)
        local lines = vim.api.nvim_buf_get_lines(0, start_l - 1, end_l, false)
        -- On nettoie les marqueurs de la sélection pour ne pas polluer l'exécution
        if lines[1]:match("^# %%") or lines[1]:match("^```") then start_l = start_l + 1 end
        if start_l <= end_l then
          vim.cmd(string.format("silent! %d,%dMoltenEvaluateVisual", start_l, end_l))
        end
      end

      -- DÉTECTION DE CELLULE
      _G.molten_get_cell_range = function()
        local cursor_line = vim.api.nvim_win_get_cursor(0)[1]
        local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
        local s = 1
        local e = #lines
        for i = cursor_line, 1, -1 do
          if lines[i]:match("^# %%") or lines[i]:match("^```python") then s = i break end
        end
        for i = cursor_line + 1, #lines do
          if lines[i]:match("^# %%") or lines[i]:match("^```") then e = i - 1 break end
        end
        return s, e
      end

      -- COMMANDES SPÉCIFIQUES
      
      -- 1. Execute Cell
      vim.api.nvim_create_user_command("MoltenRunCell", function()
        local s, e = _G.molten_get_cell_range()
        _G.molten_run_range(s, e)
      end, {})

      -- 2. Run All Above
      vim.api.nvim_create_user_command("MoltenRunAbove", function()
        local cursor_line = vim.api.nvim_win_get_cursor(0)[1]
        vim.cmd("silent! 1," .. cursor_line .. "MoltenEvaluateVisual")
        vim.notify("🚀 Exécution de tout ce qui est au-dessus", vim.log.levels.INFO)
      end, {})

      -- 3. Run All Below
      vim.api.nvim_create_user_command("MoltenRunBelow", function()
        local cursor_line = vim.api.nvim_win_get_cursor(0)[1]
        local last_line = vim.api.nvim_buf_line_count(0)
        vim.cmd("silent! " .. cursor_line .. "," .. last_line .. "MoltenEvaluateVisual")
        vim.notify("🚀 Exécution de tout ce qui est en-dessous", vim.log.levels.INFO)
      end, {})

      -- 4. Run All (Propre et Affiché)
      vim.api.nvim_create_user_command("MoltenRunAll", function()
        vim.cmd("silent! %MoltenDelete") -- Nettoyage
        vim.cmd("silent! %MoltenEvaluateVisual") -- Exécution globale (Molten affiche tout inline)
        vim.notify("✅ Tout est exécuté!", vim.log.levels.INFO)
      end, {})
    end,
    keys = {
      { "<leader>mk", ":MoltenInit python3<cr>", desc = "Init Kernel" },
      { "<leader>jc", ":MoltenRunCell<cr>", desc = "Execute Cell" },
      { "<leader>jx", ":MoltenEvaluateLine<cr>", desc = "Execute Line (Resultat Inline)" },
      { "<leader>jv", ":<C-u>MoltenEvaluateVisual<cr>", mode = "v", desc = "Execute Selection" },
      { "<leader>ja", ":MoltenRunAll<cr>", desc = "Run All" },
      { "<leader>ju", ":MoltenRunAbove<cr>", desc = "Run All Above" },
      { "<leader>jb", ":MoltenRunBelow<cr>", desc = "Run All Below" },
      { "<leader>jd", ":MoltenDelete<cr>", desc = "Delete Output" },
      { "<leader>jD", ":silent! %MoltenDelete<cr>", desc = "Delete All Outputs" },
      { "<leader>jo", ":noautocmd MoltenEnterOutput<cr>", desc = "Open Output Window" },
    },
  },

  -- Jupytext : Config stable Markdown
  {
    "GCBallesteros/jupytext.nvim",
    lazy = false,
    opts = {
      custom_outputs = false,
      style = "markdown",
      output_extension = "md",
      force_ft = "markdown", -- Coloration syntaxique Markdown native
    },
    config = function(_, opts)
      require("jupytext").setup(opts)
      vim.api.nvim_create_autocmd("BufWritePost", {
        pattern = "*.ipynb",
        callback = function()
          local base = vim.fn.expand("%:p:r")
          os.remove(base .. ".md")
          os.remove(base .. ".py")
        end,
      })
    end,
  },

  {
    "3rd/image.nvim",
    opts = {
      backend = "kitty",
      integrations = {
        markdown = { enabled = true, filetypes = { "markdown", "python" } },
      },
    },
  },
}
