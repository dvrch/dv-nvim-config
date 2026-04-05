return {
  -- 1. Molten: Configuration Professionnelle (Type VSCode)
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
      
      -- FONCTION OBLIGATOIRE : Exécuter une plage avec affichage forcé NATIVEMENT
      _G.molten_run_range = function(start_l, end_l)
        if start_l > end_l then return end
        local pos = vim.api.nvim_win_get_cursor(0)
        
        -- Création d'une simulation parfaite d'un utilisateur sélectionnant le texte au pixel près
        -- En utilisant feedkeys "x" (synchrone), Neovim traite cela instantanément comme natif.
        -- Le mode Visuel est automatiquement refermé par l'entrée de commande (:) !
        vim.api.nvim_win_set_cursor(0, {start_l, 0})
        
        local lines_down = end_l - start_l
        local keys = "V"
        if lines_down > 0 then
            keys = keys .. lines_down .. "j"
        end
        keys = keys .. ":MoltenEvaluateVisual<CR>"
        
        local seq = vim.api.nvim_replace_termcodes(keys, true, false, true)
        vim.api.nvim_feedkeys(seq, "x", false)
        
        pcall(vim.api.nvim_win_set_cursor, 0, pos)
      end

      -- DÉTECTION DES LIMITES DE CELLULES HYBRIDE (Parfaite synchro avec les décorateurs)
      _G.get_cells = function()
        local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
        local cells = {}
        
        local is_py = false
        for _, l in ipairs(lines) do
          if l:match("^# %%%%") or l:match("^# %% ") then is_py = true break end
        end

        if is_py then
          -- VUE PYTHON (# %%)
          local current_start = 1
          for i, line in ipairs(lines) do
            if line:match("^# %%%%") or line:match("^# %%") then
              if i > 1 then 
                -- Python comments (# %%) sont sûrs à envoyer au Kernel
                table.insert(cells, {s = current_start, e = i - 1, code_s = current_start, code_e = i - 1}) 
              end
              current_start = i
            end
          end
          if #lines >= current_start then
            table.insert(cells, {s = current_start, e = #lines, code_s = current_start, code_e = #lines})
          end
        else
          -- VUE MARKDOWN (```python)
          local in_code = false
          local cell_start = 1
          for i, line in ipairs(lines) do
            if line:match("^%s*```") then
              if not in_code then
                cell_start = i
                in_code = true
              else
                local cell_end = i
                -- CRITIQUE : on extrait rigoureusement le code_s et code_e pour EXCLURE
                -- les lignes de backticks (` ``` `) car elles font planter le noyau Python !
                if cell_end - 1 >= cell_start + 1 then
                  table.insert(cells, {s = cell_start, e = cell_end, code_s = cell_start + 1, code_e = cell_end - 1})
                end
                in_code = false
              end
            end
          end
        end
        return cells
      end

      -- COMMANDES SPÉCIFIQUES CELL-BY-CELL
      
      vim.api.nvim_create_user_command("MoltenRunCell", function()
        local cursor_line = vim.api.nvim_win_get_cursor(0)[1]
        local cells = _G.get_cells()
        for _, cell in ipairs(cells) do
          if cursor_line >= cell.s and cursor_line <= cell.e then
            _G.molten_run_range(cell.code_s, cell.code_e)
            break
          end
        end
      end, {})

      vim.api.nvim_create_user_command("MoltenRunVisualSmart", function()
        local start_l = vim.fn.line("'<")
        local end_l = vim.fn.line("'>")
        
        local cells = _G.get_cells()
        local intersected = {}
        for _, cell in ipairs(cells) do
           if not (cell.e < start_l or cell.s > end_l) then
             table.insert(intersected, cell)
           end
        end

        if #intersected > 0 then
           vim.notify("🚀 Multi-Run Sélection : " .. #intersected .. " cellules validées", vim.log.levels.INFO)
           local idx = 1
           local function next_c()
             if idx > #intersected then return end
             local c = intersected[idx]
             _G.molten_run_range(c.code_s, c.code_e)
             idx = idx + 1
             vim.defer_fn(next_c, 500)
           end
           next_c()
        else
           _G.molten_run_range(start_l, end_l)
        end
      end, { range = true })

      vim.api.nvim_create_user_command("MoltenDeleteAll", function()
        local pos = vim.api.nvim_win_get_cursor(0)
        local cells = _G.get_cells()
        for _, cell in ipairs(cells) do
          pcall(vim.api.nvim_win_set_cursor, 0, {cell.code_s, 0})
          vim.cmd("silent! MoltenDelete")
        end
        pcall(vim.api.nvim_win_set_cursor, 0, pos)
        vim.notify("🗑️ Tous les outputs Molten nettoyés !", vim.log.levels.INFO)
      end, {})

      vim.api.nvim_create_user_command("MoltenRunAll", function()
        vim.cmd("MoltenDeleteAll")
        local cells = _G.get_cells()
        if #cells == 0 then return end
        vim.notify("🚀 Exécution Globale (" .. #cells .. " cellules)...", vim.log.levels.INFO)
        
        local idx = 1
        local function next_c()
          if idx > #cells then 
            vim.notify("✅ Run All Terminé", vim.log.levels.INFO) 
            return 
          end
          local c = cells[idx]
          _G.molten_run_range(c.code_s, c.code_e)
          idx = idx + 1
          vim.defer_fn(next_c, 500)
        end
        next_c()
      end, {})

      vim.api.nvim_create_user_command("MoltenRunAbove", function()
        local cursor_line = vim.api.nvim_win_get_cursor(0)[1]
        local cells = _G.get_cells()
        for _, cell in ipairs(cells) do
          if cell.e < cursor_line then _G.molten_run_range(cell.code_s, cell.code_e) end
        end
      end, {})

      vim.api.nvim_create_user_command("MoltenRunBelow", function()
        local cursor_line = vim.api.nvim_win_get_cursor(0)[1]
        local cells = _G.get_cells()
        for _, cell in ipairs(cells) do
          if cell.s >= cursor_line then _G.molten_run_range(cell.code_s, cell.code_e) end
        end
      end, {})
    end,
    keys = {
      { "<leader>mk", ":MoltenInit python3<cr>", desc = "Init Kernel" },
      { "<leader>jc", ":MoltenRunCell<cr>", desc = "Execute Cell" },
      { "<leader>jx", ":MoltenEvaluateLine<cr>", desc = "Execute Line" },
      { "<leader>jv", ":<C-u>MoltenRunVisualSmart<cr>", mode = "v", desc = "Execute Smart Selection" },
      { "<leader>ja", ":MoltenRunAll<cr>", desc = "Run All Cells" },
      { "<leader>ju", ":MoltenRunAbove<cr>", desc = "Run All Above" },
      { "<leader>jb", ":MoltenRunBelow<cr>", desc = "Run All Below" },
      { "<leader>js", ":MoltenDelete<cr>", desc = "Delete Output" },
      { "<leader>jS", ":MoltenDeleteAll<cr>", desc = "Delete All Outputs" },
      { "<leader>jo", ":noautocmd MoltenEnterOutput<cr>", desc = "Open Output Window" },
    },
  },

  -- 2. Jupytext : Config stable Markdown (Avec Décorateurs ✨)
  {
    "GCBallesteros/jupytext.nvim",
    event = { "User LoadHeavy" },
    lazy = true,
    opts = {
      style = "markdown",        -- Format d affichage par défaut : MD
      output_extension = "md",   -- Extension du fichier temporaire : .md
      force_ft = "markdown",     -- Filetype Neovim : markdown
    },
    config = function(_, opts)
      require("jupytext").setup(opts)
      local jd = require("util.jupyter_decorator")

      -- 🔄 NETTOYAGE SIDECARS
      local function cleanup_sidecars()
        local base = vim.fn.expand("%:p:r")
        if base == "" then return end
        os.remove(base .. ".md")
        os.remove(base .. ".py")
      end

      -- Format par défaut
      if vim.g.jupytext_user_fmt == nil then
        vim.g.jupytext_user_fmt = "markdown"
      end

      -- 🔄 TOGGLE ATOMIQUE
      vim.api.nvim_create_user_command("JupyterToggleView", function()
        if vim.bo.modified then vim.cmd("w") end
        cleanup_sidecars()

        local current = vim.g.jupytext_user_fmt or "markdown"
        local target = (current == "markdown") and "py:percent" or "markdown"
        vim.g.jupytext_user_fmt = target

        if target == "markdown" then
          require("jupytext").setup({ style = "markdown", output_extension = "md", force_ft = "markdown" })
        else
          require("jupytext").setup({ style = "hydrogen", output_extension = "py", force_ft = "python" })
        end

        vim.notify("🚀 Vue : " .. (target == "markdown" and "MARKDOWN ✨" or "PYTHON 🐍"), vim.log.levels.WARN)
        vim.cmd("e!")
      end, {})

      -- ⌨️ RACCOURCIS
      vim.keymap.set("n", "<leader>jt", "<cmd>JupyterToggleView<cr>", { desc = "Jupyter: Bascule MD/PY" })
      vim.keymap.set("n", "<leader>jd", function() jd.toggle() end, { desc = "Toggle Décorations Cellules" })
      vim.keymap.set("n", "<leader>jw", "<cmd>JSync<cr>", { desc = "Jupyter Sync (To IPYNB)" })
      vim.keymap.set("n", "<leader>ip", ":cd /home/kd/scripts | e agent_brain.ipynb<CR>", { desc = "🚀 Pont Agent" })

      -- ⚡ AUTOMATISME DÉCORATIONS
      vim.api.nvim_create_autocmd("BufReadPre", {
        pattern = "*.ipynb",
        callback = function(ev)
          vim.b[ev.buf].jupytext_fmt = vim.g.jupytext_user_fmt or "markdown"
        end,
      })

      vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter", "BufWritePost", "TextChanged", "InsertLeave" }, {
        pattern = { "*.ipynb", "*.md", "*.txt" },
        callback = function(ev)
          if vim.api.nvim_buf_is_valid(ev.buf) then
            jd.decorate(ev.buf)
          end
        end,
      })

      -- Nettoyage auto après sauvegarde
      vim.api.nvim_create_autocmd("BufWritePost", {
        pattern = "*.ipynb",
        callback = cleanup_sidecars,
      })

      -- 🔄 FILE WATCHER
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
      vim.api.nvim_create_user_command("JSync", function()
        local path = vim.api.nvim_buf_get_name(0)
        local ext = path:match("%.(%w+)$")
        if ext == "md" or ext == "txt" then
          local ipynb = path:gsub("%.%w+$", ".ipynb")
          -- On s'assure que jupytext peut traiter le fichier (force conversion vs ipynb)
          vim.fn.system({ "jupytext", "--update", "--set-kernel", "python3_nvim", "--to", "ipynb", path })
          vim.notify("🔄 IPYNB Synchronisé : " .. vim.fn.fnamemodify(ipynb, ":t"), vim.log.levels.INFO)
        else
          vim.notify("🔴 JSync possible uniquement sur .md ou .txt", vim.log.levels.ERROR)
        end
      end, {})
      vim.api.nvim_create_user_command("JDecorateToggle", function() jd.toggle() end, {})
      vim.api.nvim_create_user_command("JDecorate", function() jd.decorate() end, {})
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
