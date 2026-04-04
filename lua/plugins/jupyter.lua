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
    opts = {}, -- ⚠️ PAS de style/output_extension ici → ça corrompt le .ipynb !
    config = function(_, opts)
      require("jupytext").setup(opts)

      -- 🔄 NETTOYAGE SIDECARS
      local function cleanup_sidecars()
        local base = vim.fn.expand("%:p:r")
        if base == "" then return end
        os.remove(base .. ".md")
        os.remove(base .. ".py")
      end

      -- 🔄 TOGGLE ATOMIQUE (MD <-> PY)
      vim.api.nvim_create_user_command("JupyterToggleView", function()
        if vim.bo.modified then vim.cmd("w") end
        local current = vim.b.jupytext_fmt or "markdown"
        local target = (current == "markdown") and "py:percent" or "markdown"
        cleanup_sidecars()
        vim.notify("🚀 Vue : " .. (target == "markdown" and "MARKDOWN" or "PYTHON"), vim.log.levels.WARN)
        vim.b.jupytext_fmt = target
        vim.cmd("e!")
      end, {})

      -- ⌨️ RACCOURCIS
      vim.keymap.set("n", "<leader>jv", "<cmd>JupyterToggleView<cr>", { desc = "Jupyter: Bascule MD/PY" })
      vim.keymap.set("n", "<leader>ip", ":cd /home/kd/scripts | e agent_brain.ipynb<CR>", { desc = "🚀 Pont Agent" })

      -- 🎨 DÉCORATIONS "GHOST" PERMANENTES ET UNIVERSELLES
      local ns_cell = vim.api.nvim_create_namespace("jupyter_ghost_lines")
      local function decorate_cells(buf)
        buf = buf or vim.api.nvim_get_current_buf()
        if not vim.api.nvim_buf_is_valid(buf) then return end
        vim.api.nvim_buf_clear_namespace(buf, ns_cell, 0, -1)
        vim.opt_local.conceallevel = 2

        local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
        local fmt = vim.b[buf].jupytext_fmt or "markdown"
        local is_py = fmt == "py:percent"

        for i, line in ipairs(lines) do

          -- 🏷️ BALISES VISIBLES NON-ÉDITABLES (Virt Lines permanentes)

          -- Marqueur de REGION Jupytext (début de bloc Markdown)
          if line:find("#region", 1, true) or line:find("<!-- #region", 1, true) then
            vim.api.nvim_buf_set_extmark(buf, ns_cell, i - 1, 0, {
              virt_lines = { { { "┄┄┄ ◈ DÉBUT RÉGION MARKDOWN ◈ ┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄", "DiagnosticHint" } } },
              virt_lines_above = true, priority = 2100,
            })
          -- Marqueur de FIN REGION Jupytext
          elseif line:find("#endregion", 1, true) or line:find("<!-- #endregion", 1, true) then
            vim.api.nvim_buf_set_extmark(buf, ns_cell, i - 1, 0, {
              virt_lines = { { { "┄┄┄ ◇ FIN RÉGION MARKDOWN ◇ ┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄", "DiagnosticHint" } } },
              virt_lines_above = false, priority = 2100,
            })
          end

          if not is_py then
            -- === VUE MARKDOWN : ```python → DÉBUT, ``` seul → FIN ===
            if line:find("```python", 1, true) then
              vim.api.nvim_buf_set_extmark(buf, ns_cell, i - 1, 0, {
                virt_lines = { { { "⚡ [ CELLULE CODE ] ──────────────────────────────────────────────", "Special" } } },
                virt_lines_above = true,
                priority = 2000,
              })
            elseif line:find("```", 1, true) and not line:find("python", 1, true) then
              vim.api.nvim_buf_set_extmark(buf, ns_cell, i - 1, 0, {
                virt_lines = { { { "🏁 [ FIN CELLULE CODE ] ─────────────────────────────────────────", "Comment" } } },
                virt_lines_above = false,
                priority = 2000,
              })
            end
          else
            -- === VUE PYTHON : # %% → DÉBUT CELLULE + FIN de la précédente ===
            if line:find("# %% [markdown]", 1, true) then
              -- Fin de la cellule précédente (au-dessus)
              vim.api.nvim_buf_set_extmark(buf, ns_cell, i - 1, 0, {
                virt_lines = { { { "🏁 [ FIN CELLULE ] ──────────────────────────────────────────────", "Comment" } } },
                virt_lines_above = true,
                priority = 2000,
              })
              -- Début de cette cellule Markdown (en-dessous)
              vim.api.nvim_buf_set_extmark(buf, ns_cell, i - 1, 0, {
                virt_lines = { { { "📝 [ CELLULE MARKDOWN ] ─────────────────────────────────────────", "String" } } },
                virt_lines_above = false,
                priority = 1999,
              })
            elseif line:find("# %%", 1, true) and not line:find("markdown", 1, true) then
              -- Fin de la cellule précédente (au-dessus)
              if i > 1 then
                vim.api.nvim_buf_set_extmark(buf, ns_cell, i - 1, 0, {
                  virt_lines = { { { "🏁 [ FIN CELLULE ] ──────────────────────────────────────────────", "Comment" } } },
                  virt_lines_above = true,
                  priority = 2000,
                })
              end
              -- Début de cette cellule Code (en-dessous)
              vim.api.nvim_buf_set_extmark(buf, ns_cell, i - 1, 0, {
                virt_lines = { { { "⚡ [ CELLULE CODE ] ──────────────────────────────────────────────", "Special" } } },
                virt_lines_above = false,
                priority = 1999,
              })
            end
          end
        end
      end

      -- ⚡ AUTOMATISMES (Forçage MD par défaut + Décorations)
      vim.api.nvim_create_autocmd("BufReadPre", {
        pattern = "*.ipynb",
        callback = function(ev)
          cleanup_sidecars()
          if not vim.b[ev.buf].jupytext_fmt then
            vim.b[ev.buf].jupytext_fmt = "markdown"
          end
        end,
      })

      vim.api.nvim_create_autocmd({ "BufWinEnter", "BufWritePost", "TextChanged", "InsertLeave", "CursorHold" }, {
        pattern = "*.ipynb",
        callback = function(ev)
          vim.defer_fn(function()
            if vim.api.nvim_buf_is_valid(ev.buf) then
              decorate_cells(ev.buf)
            end
          end, 50)
        end,
      })

      -- Nettoyage auto après sauvegarde
      vim.api.nvim_create_autocmd("BufWritePost", {
        pattern = "*.ipynb",
        callback = cleanup_sidecars,
      })

      -- 🔄 FILE WATCHER (Temps Réel)
      local watcher = nil
      local function start_watching(buf)
        if watcher then watcher:stop() end
        local path = vim.api.nvim_buf_get_name(buf)
        if path == "" or not path:find("agent_brain.ipynb") then return end
        watcher = vim.loop.new_fs_event()
        watcher:start(path, {}, vim.schedule_wrap(function(err)
          if not err and vim.api.nvim_buf_is_valid(buf) and not vim.bo[buf].modified then
            local fmt = vim.b[buf].jupytext_fmt
            vim.cmd("e!")
            vim.b[buf].jupytext_fmt = fmt
          end
        end))
      end

      vim.api.nvim_create_autocmd("BufWinEnter", {
        pattern = "*.ipynb",
        callback = function(ev) start_watching(ev.buf) end,
      })

      vim.opt.autoread = true
      vim.api.nvim_create_user_command("JupyterDecorate", function() decorate_cells() end, {})
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

