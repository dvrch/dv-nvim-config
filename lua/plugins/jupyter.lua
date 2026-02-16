return {
  -- Molten: Moteur d'exécution robuste
  {
    "benlubas/molten-nvim",
    version = "^1.0.0",
    build = ":UpdateRemotePlugins",
    init = function()
      -- Configuration affichage
      vim.g.molten_auto_open_output = true
      vim.g.molten_virt_text_output = true
      vim.g.molten_virt_lines_off_by_1 = false
      vim.g.molten_output_win_max_height = 20
      vim.g.molten_wrap_output = true
      vim.g.molten_image_provider = "image.nvim"
      
      -- FONCTION DE SECOURS : Exécuter la plage manuellement (Détection de cellule)
      _G.molten_execute_manual_cell = function()
        local cursor_line = vim.api.nvim_win_get_cursor(0)[1]
        local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
        local start_line = 1
        local end_line = #lines

        -- Trouver le début (le # %% ou ``` précédent)
        for i = cursor_line, 1, -1 do
          if lines[i]:match("^# %%") or lines[i]:match("^```python") then
            start_line = i
            break
          end
        end

        -- Trouver la fin (le # %% ou ``` suivant)
        for i = cursor_line + 1, #lines do
          if lines[i]:match("^# %%") or lines[i]:match("^```") then
            end_line = i - 1
            break
          end
        end

        -- Exécuter la plage avec MoltenEvaluateVisual (qui accepte une plage numérique)
        -- Note: On évite les lignes de délimitation
        if lines[start_line]:match("^# %%") or lines[start_line]:match("^```") then
          start_line = start_line + 1
        end
        
        if start_line <= end_line then
          vim.cmd(string.format("silent! %d,%dMoltenEvaluateVisual", start_line, end_line))
        else
          vim.notify("Cellule vide", vim.log.levels.WARN)
        end
      end

      -- Commande: Kill All
      vim.api.nvim_create_user_command("MoltenKillAll", function()
        vim.cmd("MoltenDeinit")
        vim.fn.system("pkill -9 -f ipykernel")
        vim.notify("💀 Kernels nettoyés", vim.log.levels.WARN)
      end, {})

      -- Commande: Run All améliorée
      vim.api.nvim_create_user_command("MoltenRunAll", function()
        local old_auto = vim.g.molten_auto_open_output
        vim.g.molten_auto_open_output = false
        vim.cmd("silent! %MoltenDelete")
        
        local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
        local cells = {}
        for i, line in ipairs(lines) do
          if line:match("^# %%") or line:match("^```python") then
            table.insert(cells, i)
          end
        end

        if #cells == 0 then
          vim.notify("❌ Aucune cellule détective", vim.log.levels.ERROR)
          vim.g.molten_auto_open_output = old_auto
          return
        end

        local curr = 1
        local function run_next()
          if curr > #cells then
            vim.notify("✅ Run All Terminé", vim.log.levels.INFO)
            vim.g.molten_auto_open_output = old_auto
            return
          end
          vim.api.nvim_win_set_cursor(0, {cells[curr], 0})
          _G.molten_execute_manual_cell()
          curr = curr + 1
          vim.defer_fn(run_next, 1200)
        end
        run_next()
      end, {})
    end,
    keys = {
      { "<leader>mk", ":MoltenInit python3<cr>", desc = "Init Kernel" },
      { "<leader>jc", function() _G.molten_execute_manual_cell() end, desc = "Execute Cell (Manual Detection)" },
      { "<leader>jx", ":MoltenEvaluateLine<cr>", desc = "Execute Line" },
      { "<leader>jv", ":<C-u>MoltenEvaluateVisual<cr>", mode = "v", desc = "Execute Selection" },
      { "<leader>ja", ":MoltenRunAll<cr>", desc = "Run All Cells" },
      { "<leader>jd", ":MoltenDelete<cr>", desc = "Delete Output" },
      { "<leader>jD", ":silent! %MoltenDelete<cr>", desc = "Delete All Outputs" },
      { "<leader>jo", ":noautocmd MoltenEnterOutput<cr>", desc = "Open Output" },
    },
  },

  -- Jupytext : MODE MARKDOWN pour coloration mixte
  {
    "GCBallesteros/jupytext.nvim",
    lazy = false,
    opts = {
      custom_outputs = false,
      style = "markdown", 
      output_extension = "md",
      force_ft = "markdown", -- Coloration native Markdown ✅
    },
    config = function(_, opts)
      require("jupytext").setup(opts)
      -- Nettoyage fichiers temporaires
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
