return {
  "GCBallesteros/jupytext.nvim",
  config = function()
    require("jupytext").setup({
      style = "markdown",
      output_extension = "md",
      force_ft = "markdown",
    })

    -- 🛡️ PROTECTIONS ANTI-CORRUPTION & RESTAURATION
    local function backup_ipynb(buf)
      local path = vim.api.nvim_buf_get_name(buf)
      if not path:match("%.ipynb$") then return end
      local content = vim.fn.readfile(path)
      if content and #content > 0 then
        -- On garde un backup JSON pur dans l'artifact de l'agent si possible,
        -- ou simplement un fichier caché local.
        vim.fn.writefile(content, "/tmp/last_safe_jupyter.json")
      end
    end

    local function restore_ipynb()
      local path = vim.api.nvim_buf_get_name(0)
      if not path:match("%.ipynb$") then 
        print("❌ Pas un fichier .ipynb")
        return 
      end
      if vim.fn.filereadable("/tmp/last_safe_jupyter.json") == 1 then
        local content = vim.fn.readfile("/tmp/last_safe_jupyter.json")
        vim.fn.writefile(content, path)
        vim.cmd("e!")
        print("✅ Notebook restauré depuis le dernier backup sain.")
      else
        print("❌ Aucun backup trouvé.")
      end
    end

    -- Nettoyage des sidecars (.md, .py) après sauvegarde pour éviter de polluer scripts/
    local function cleanup_sidecars()
      local path = vim.api.nvim_buf_get_name(0)
      local base = path:gsub("%.ipynb$", "")
      for _, ext in ipairs({ ".md", ".py" }) do
        local sidecar = base .. ext
        if vim.fn.filereadable(sidecar) == 1 then
          os.remove(sidecar)
        end
      end
    end

    -- 🚀 TOGGLE VUE ATOMIQUE (Bascule MD <-> PY sans corruption)
    local function jupyter_toggle_view()
      vim.cmd("w") -- Sauvegarde forcée avant bascule
      local buf = vim.api.nvim_get_current_buf()
      local current_fmt = vim.b[buf].jupytext_fmt or "markdown"
      local next_fmt = (current_fmt == "markdown") and "py:percent" or "markdown"
      
      -- Stockage global pour persistance après e!
      vim.g.jupytext_user_fmt = next_fmt
      vim.b[buf].jupytext_fmt = next_fmt
      
      -- Reconfiguration dynamique
      require("jupytext").setup({ style = next_fmt, force_ft = (next_fmt == "markdown" and "markdown" or "python") })
      
      cleanup_sidecars()
      vim.cmd("e!")
      vim.notify("🌓 Vue Jupytext basculée : " .. next_fmt, vim.log.levels.INFO)
    end

    vim.api.nvim_create_user_command("JupyterRestore", restore_ipynb, {})
    vim.api.nvim_create_user_command("JupyterToggleView", jupyter_toggle_view, {})
    vim.api.nvim_create_user_command("JupyterDecorate", function() 
      local buf = vim.api.nvim_get_current_buf()
      decorate_cells(buf) 
    end, {})

    -- ⌨️ RACCOURCIS
    vim.keymap.set("n", "<leader>jv", "<cmd>JupyterToggleView<cr>", { desc = "Jupyter: Bascule MD/PY" })
    vim.keymap.set("n", "<leader>ip", ":cd /home/kd/scripts | e agent_brain.ipynb<CR>", { desc = "🚀 Pont Agent" })

    -- 🎨 DÉCORATIONS "GHOST" — SYSTÈME DYNAMIQUE (DÉTECTION LANGAGE & ÉDITION)
    local ns_cell = vim.api.nvim_create_namespace("jupyter_ghost_lines")

    function decorate_cells(buf)
      buf = buf or vim.api.nvim_get_current_buf()
      if not vim.api.nvim_buf_is_valid(buf) then return end
      vim.api.nvim_buf_clear_namespace(buf, ns_cell, 0, -1)
      
      vim.opt_local.conceallevel = 2
      vim.opt_local.concealcursor = "nvic"

      local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
      local cursor_line = vim.api.nvim_win_get_cursor(0)[1]

      -- Détection format (scan rapide)
      local is_py = false
      for _, l in ipairs(lines) do
        if l:match("^# %%%%") or l:match("^# %% ") then is_py = true; break end
      end

      local in_code_block = false

      for i, line in ipairs(lines) do
        -- 🧼 MASQUAGE CONDITIONNEL (Visible si le curseur est dessus)
        local function hide_line()
          if i == cursor_line then return end -- NE PAS CACHER SI ÉDITION EN COURS
          local mask = string.rep(" ", math.max(#line, 1))
          vim.api.nvim_buf_set_extmark(buf, ns_cell, i - 1, 0, {
            virt_text = { { mask, "Conceal" } },
            virt_text_pos = "overlay",
            priority = 2500,
          })
        end

        if not is_py then
          -- ══════════════ VUE MARKDOWN (DESIGN) ══════════════
          
          -- 1. Cellules Markdown (Régions)
          if line:match("<!-- #endregion") or line:match("#endregion") then
            hide_line()
            vim.api.nvim_buf_set_extmark(buf, ns_cell, i - 1, 0, {
              virt_lines = { { { "   ╚══ FIN CELLULE MARKDOWN ═════════════════════════════════════╝", "Comment" } } },
              virt_lines_above = false, priority = 2400 })
          
          elseif line:match("<!-- #region") or line:match("#region") then
            hide_line()
            vim.api.nvim_buf_set_extmark(buf, ns_cell, i - 1, 0, {
              virt_lines = { { { "📝 ╔══ CELLULE MARKDOWN ══════════════════════════════════════════╗", "String" } } },
              virt_lines_above = true, priority = 2400 })

          -- 2. Cellules CODE (Détection Dynamique du Langage)
          elseif line:match("^%s*```") then
            hide_line()
            if not in_code_block then
              local lang = line:match("^%s*```(%w+)") or "Python"
              vim.api.nvim_buf_set_extmark(buf, ns_cell, i - 1, 0, {
                virt_lines = { { { "⚡ ╔══ CELLULE CODE (" .. lang .. ") ════════════════════════════════", "Special" } } },
                virt_lines_above = true, priority = 2400 })
              in_code_block = true
            else
              vim.api.nvim_buf_set_extmark(buf, ns_cell, i - 1, 0, {
                virt_lines = { { { "   ╚══ FIN CELLULE CODE ══════════════════════════════════════════╝", "Comment" } } },
                virt_lines_above = false, priority = 2400 })
              in_code_block = false
            end
          end

        else
          -- ══════════════ VUE PYTHON (EXPERT) ══════════════
          if line:find("# %% [markdown]", 1, true) then
            hide_line()
            if i > 1 then
              vim.api.nvim_buf_set_extmark(buf, ns_cell, i - 1, 0, {
                virt_lines = { { { "   ╚══ FIN CELLULE ═══════════════════════════════════════════════╝", "Comment" } } },
                virt_lines_above = true, priority = 2400 })
            end
            vim.api.nvim_buf_set_extmark(buf, ns_cell, i - 1, 0, {
              virt_lines = { { { "📝 ╔══ CELLULE MARKDOWN ══════════════════════════════════════════╗", "String" } } },
              virt_lines_above = false, priority = 2399 })

          elseif line:find("# %%", 1, true) and not line:find("markdown", 1, true) then
            hide_line()
            if i > 1 then
              vim.api.nvim_buf_set_extmark(buf, ns_cell, i - 1, 0, {
                virt_lines = { { { "   ╚══ FIN CELLULE ═══════════════════════════════════════════════╝", "Comment" } } },
                virt_lines_above = true, priority = 2400 })
            end
            vim.api.nvim_buf_set_extmark(buf, ns_cell, i - 1, 0, {
              virt_lines = { { { "⚡ ╔══ CELLULE CODE (Python) ══════════════════════════════════════╗", "Special" } } },
              virt_lines_above = false, priority = 2399 })
          end
        end
      end
    end

    -- ⚡ AUTOMATISMES (Mis à jour pour réactivité curseur)
    vim.api.nvim_create_autocmd({ "BufWinEnter", "BufWritePost", "TextChanged", "InsertLeave", "CursorHold", "CursorMoved" }, {
      pattern = "*.ipynb",
      callback = function(ev)
        vim.defer_fn(function()
          if vim.api.nvim_buf_is_valid(ev.buf) then decorate_cells(ev.buf) end
        end, 20)
      end,
    })

    -- Forçage MD au chargement
    vim.api.nvim_create_autocmd("BufReadPre", {
      pattern = "*.ipynb",
      callback = function(ev)
        vim.b[ev.buf].jupytext_fmt = vim.g.jupytext_user_fmt or "markdown"
      end,
    })

    -- Backup automatique
    vim.api.nvim_create_autocmd("BufReadPost", {
      pattern = "*.ipynb",
      callback = function(ev) backup_ipynb(ev.buf) end,
    })

    -- 🔄 SYNCHRONISATION INVERSE : Markdown -> IPYNB
    vim.api.nvim_create_autocmd("BufWritePost", {
      pattern = "*.md",
      callback = function(ev)
        local md_path = ev.match
        local ipynb_path = md_path:gsub("%.md$", ".ipynb")
        if vim.fn.filereadable(ipynb_path) == 1 then
          vim.fn.jobstart({ "jupytext", "--update", "--to", "ipynb", md_path }, {
            on_exit = function()
              vim.notify("🔄 Notebook synchronisé : " .. vim.fn.fnamemodify(ipynb_path, ":t"), vim.log.levels.INFO)
            end
          })
        end
      end,
    })

    -- Nettoyage sidecars systématique
    vim.api.nvim_create_autocmd("BufWritePost", {
      pattern = "*.ipynb",
      callback = cleanup_sidecars,
    })
  end,
}
