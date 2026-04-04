return {
  -- Molten: Configuration Professionnelle (Type VSCode)
  {
    "benlubas/molten-nvim",
    event = { "User LoadHeavy" },
    version = "^1.0.0",
    build = ":UpdateRemotePlugins",
    init = function()
      -- CONFIGURATION AFFICHAGE (Identique à VSCode)
      vim.g.molten_auto_open_output = true
      vim.g.molten_virt_text_output = true
      vim.g.molten_virt_lines_off_by_1 = false
      vim.g.molten_output_win_max_height = 20
      vim.g.molten_wrap_output = true
      vim.g.molten_image_provider = "image.nvim"
      
      -- FONCTION DE SECOURS : Exécuter une plage avec affichage forcé
      _G.molten_run_range = function(start_l, end_l)
        if start_l > end_l then return end
        vim.cmd(string.format("silent! %d,%dMoltenEvaluateVisual", start_l, end_l))
      end

      -- DÉTECTION DES LIMITES DE CELLULES
      _G.get_cells = function()
        local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
        local cells = {}
        local current_start = 1
        for i, line in ipairs(lines) do
          if line:match("^# %%") or line:match("^```python") then
            if i > 1 then table.insert(cells, {s = current_start, e = i - 1}) end
            current_start = i
          end
        end
        table.insert(cells, {s = current_start, e = #lines})
        return cells
      end

      -- COMMANDES SPÉCIFIQUES CELL-BY-CELL (Pour voir les résultats partout)
      
      -- 1. Execute Cell
      vim.api.nvim_create_user_command("MoltenRunCell", function()
        local cursor_line = vim.api.nvim_win_get_cursor(0)[1]
        local cells = _G.get_cells()
        for _, cell in ipairs(cells) do
          if cursor_line >= cell.s and cursor_line <= cell.e then
            _G.molten_run_range(cell.s, cell.e)
            break
          end
        end
      end, {})

      -- 2. Run All (Séquentiel pour voir les résultats sous chaque cellule)
      vim.api.nvim_create_user_command("MoltenRunAll", function()
        vim.cmd("silent! %MoltenDelete")
        local cells = _G.get_cells()
        vim.notify("🚀 Exécution de " .. #cells .. " cellules...", vim.log.levels.INFO)
        
        local idx = 1
        local function next_c()
          if idx > #cells then 
            vim.notify("✅ Run All Terminé", vim.log.levels.INFO) 
            return 
          end
          local c = cells[idx]
          _G.molten_run_range(c.s, c.e)
          idx = idx + 1
          vim.defer_fn(next_c, 500) -- Délai pour laisser l'output s'afficher
        end
        next_c()
      end, {})

      -- 3. Run Above / Below
      vim.api.nvim_create_user_command("MoltenRunAbove", function()
        local cursor_line = vim.api.nvim_win_get_cursor(0)[1]
        local cells = _G.get_cells()
        for _, cell in ipairs(cells) do
          if cell.e < cursor_line then _G.molten_run_range(cell.s, cell.e) end
        end
      end, {})

      vim.api.nvim_create_user_command("MoltenRunBelow", function()
        local cursor_line = vim.api.nvim_win_get_cursor(0)[1]
        local cells = _G.get_cells()
        for _, cell in ipairs(cells) do
          if cell.s >= cursor_line then _G.molten_run_range(cell.s, cell.e) end
        end
      end, {})
    end,
    keys = {
      { "<leader>mk", ":MoltenInit python3<cr>", desc = "Init Kernel" },
      { "<leader>jc", ":MoltenRunCell<cr>", desc = "Execute Cell" },
      { "<leader>jx", ":MoltenEvaluateLine<cr>", desc = "Execute Line (Resultat Inline)" },
      { "<leader>jv", ":<C-u>MoltenEvaluateVisual<cr>", mode = "v", desc = "Execute Selection" },
      { "<leader>ja", ":MoltenRunAll<cr>", desc = "Run All Cells" },
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
    event = { "User LoadHeavy" },
    lazy = true,
    opts = {
      custom_outputs = false,
      style = "markdown",
      output_extension = "md",
      force_ft = "markdown",
    },
    config = function(_, opts)
      require("jupytext").setup(opts)

      -- 🎨 DÉCORATIONS VISUELLES "GHOST" (Ne s'enregistrent pas)
      local ns_cell = vim.api.nvim_create_namespace("jupyter_ghost_cells")
      local function decorate_cells()
        local buf = vim.api.nvim_get_current_buf()
        if vim.bo[buf].filetype ~= "markdown" then return end
        
        vim.api.nvim_buf_clear_namespace(buf, ns_cell, 0, -1)
        local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
        
        for i, line in ipairs(lines) do
          if line:find("```python") then
            -- Balise de Début
            vim.api.nvim_buf_set_extmark(buf, ns_cell, i - 1, 0, {
              virt_text = { { "#<<<< [ DÉBUT CELLULE CODE ] ──────────────────", "DiagnosticVirtualTextInfo" } },
              virt_text_pos = "right_align",
            })
          elseif line:find("```") and not line:find("python") then
            -- Balise de Fin
            vim.api.nvim_buf_set_extmark(buf, ns_cell, i - 1, 0, {
              virt_text = { { "#>>>> [ FIN CELLULE CODE ] ────────────────────", "DiagnosticVirtualTextInfo" } },
              virt_text_pos = "right_align",
            })
          end
        end
      end

      -- Déclenchement automatique transparent
      vim.api.nvim_create_autocmd({ "BufWinEnter", "BufWritePost", "TextChanged", "InsertLeave" }, {
        pattern = "*.ipynb",
        callback = function()
          vim.defer_fn(decorate_cells, 50) -- Petit délai pour laisser Jupytext finir son rendu
        end,
      })

      -- Nettoyage automatique des fichiers résiduels lors du save
      vim.api.nvim_create_autocmd("BufWritePost", {
        pattern = "*.ipynb",
        callback = function()
          local base = vim.fn.expand("%:p:r")
          os.remove(base .. ".md")
          os.remove(base .. ".py")
        end,
      })

      -- Raccourci de secours
      vim.keymap.set("n", "<leader>ip", ":cd /home/kd/scripts | e agent_brain.ipynb<CR>", { desc = "🚀 Pont Agent" })
      vim.api.nvim_create_user_command("JupyterDecorate", decorate_cells, {})
    end,
  },

  {
    "3rd/image.nvim",
    event = { "User LoadHeavy" },
    opts = {
      backend = "kitty",
      integrations = {
        markdown = { enabled = true, filetypes = { "markdown", "python" } },
      },
    },
  },
}
