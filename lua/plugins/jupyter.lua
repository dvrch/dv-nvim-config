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
      local path = vim.api.nvim_buf_get_name(buf or 0)
      if not path:match("%.ipynb$") then return end
      local content = vim.fn.readfile(path)
      if content and #content > 0 then
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
        print("✅ Notebook restauré.")
      else
        print("❌ Aucun backup trouvé.")
      end
    end

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

    local function jupyter_toggle_view()
      vim.cmd("w")
      local buf = vim.api.nvim_get_current_buf()
      local current_fmt = vim.b[buf].jupytext_fmt or "markdown"
      local next_fmt = (current_fmt == "markdown") and "py:percent" or "markdown"
      vim.g.jupytext_user_fmt = next_fmt
      vim.b[buf].jupytext_fmt = next_fmt
      require("jupytext").setup({ style = next_fmt, force_ft = (next_fmt == "markdown" and "markdown" or "python") })
      cleanup_sidecars()
      vim.cmd("e!")
      vim.notify("🌓 Vue Jupytext : " .. next_fmt, vim.log.levels.INFO)
    end

    vim.api.nvim_create_user_command("JupyterToggleView", jupyter_toggle_view, {})
    vim.api.nvim_create_user_command("JupyterRestore", restore_ipynb, {})
    vim.api.nvim_create_user_command("JupyterDecorate", function() decorate_cells(0) end, {})

    vim.keymap.set("n", "<leader>jv", "<cmd>JupyterToggleView<cr>", { desc = "Jupyter: Toggle MD/PY" })
    vim.keymap.set("n", "<leader>ip", ":cd /home/kd/scripts | e agent_brain.ipynb<CR>", { desc = "🚀 Pont Agent" })

    -- 🎨 DÉCORATEUR UNIVERSEL (Appliqué à tout .ipynb)
    local ns_cell = vim.api.nvim_create_namespace("jupyter_ghost_lines")

    function decorate_cells(buf)
      buf = (buf == 0 or buf == nil) and vim.api.nvim_get_current_buf() or buf
      if not vim.api.nvim_buf_is_valid(buf) then return end
      vim.api.nvim_buf_clear_namespace(buf, ns_cell, 0, -1)
      
      -- Forçage visuel
      vim.opt_local.conceallevel = 2
      vim.opt_local.concealcursor = "nvic"

      local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
      local cursor_line = vim.api.nvim_win_get_cursor(0)[1]

      local is_py = false
      for _, l in ipairs(lines) do
        if l:match("^# %%%%") or l:match("^# %% ") then is_py = true; break end
      end

      local in_code_block = false

      for i, line in ipairs(lines) do
        local function hide_line()
          if i == cursor_line then return end 
          local mask = string.rep(" ", math.max(#line, 1))
          vim.api.nvim_buf_set_extmark(buf, ns_cell, i - 1, 0, {
            virt_text = { { mask, "Conceal" } },
            virt_text_pos = "overlay",
            priority = 2500,
          })
        end

        if not is_py then
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

    -- 🔄 AUTOMATISMES UNIVERSELS
    vim.api.nvim_create_autocmd({ "BufWinEnter", "BufWritePost", "TextChanged", "InsertLeave", "CursorMoved" }, {
      pattern = "*.ipynb",
      callback = function(ev)
        vim.defer_fn(function()
          if vim.api.nvim_buf_is_valid(ev.buf) then decorate_cells(ev.buf) end
        end, 10)
      end,
    })

    vim.api.nvim_create_autocmd("BufReadPre", {
      pattern = "*.ipynb",
      callback = function(ev)
        vim.b[ev.buf].jupytext_fmt = vim.g.jupytext_user_fmt or "markdown"
      end,
    })

    vim.api.nvim_create_autocmd("BufReadPost", {
      pattern = "*.ipynb",
      callback = function(ev) backup_ipynb(ev.buf) end,
    })

    vim.api.nvim_create_autocmd("BufWritePost", {
      pattern = "*.md",
      callback = function(ev)
        local md_path = ev.match
        local ipynb_path = md_path:gsub("%.md$", ".ipynb")
        if vim.fn.filereadable(ipynb_path) == 1 then
          vim.fn.jobstart({ "jupytext", "--update", "--to", "ipynb", md_path })
        end
      end,
    })

    vim.api.nvim_create_autocmd("BufWritePost", {
      pattern = "*.ipynb",
      callback = cleanup_sidecars,
    })
  end,
}
