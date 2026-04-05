return {
  -- 1. Molten: Exécution & Output
  {
    "benlubas/molten-nvim",
    event = { "BufRead *.ipynb", "BufRead *.md" },
    build = ":UpdateRemotePlugins",
    init = function()
      vim.g.molten_auto_open_output = true
      vim.g.molten_virt_text_output = true
      vim.g.molten_output_win_max_height = 20
      vim.g.molten_image_provider = "image.nvim"
    end,
  },

  -- 2. Jupytext: Le Pont Invisible (MD First)
  {
    "GCBallesteros/jupytext.nvim",
    event = { "BufReadPre *.ipynb", "BufNewFile *.ipynb", "BufRead *.md" },
    lazy = false, 
    opts = { style = "markdown", output_extension = "md", force_ft = "markdown" },
    config = function(_, opts)
      require("jupytext").setup(opts)

      -- 🎨 SYSTÈME DE COULEURS PERSISTANT (V3.3)
      local function set_colors()
        vim.api.nvim_set_hl(0, "JupyterMdHeader", { fg = "#FFD700", bold = true, default = true })
        vim.api.nvim_set_hl(0, "JupyterCodeHeader", { fg = "#FF8C00", bold = true, default = true })
        vim.api.nvim_set_hl(0, "JupyterFooter", { fg = "#5c6370", italic = true, default = true })
      end
      set_colors()

      local ns_cell = vim.api.nvim_create_namespace("jupyter_ghost_lines")

      -- 🎨 DÉCORATEUR "ULTRA-SYNC" (MD & IPYNB IDENTIQUES)
      function do_decorate(buf)
        buf = (buf == 0 or buf == nil) and vim.api.nvim_get_current_buf() or buf
        if not vim.api.nvim_buf_is_valid(buf) then return end
        
        local name = vim.api.nvim_buf_get_name(buf)
        local is_jupyter = name:match("%.ipynb") or name:match("%.md") or vim.b[buf].jupytext_fmt
        if not is_jupyter then return end

        vim.api.nvim_buf_clear_namespace(buf, ns_cell, 0, -1)
        set_colors() -- Force refresh colors
        
        vim.opt_local.conceallevel = 2
        vim.opt_local.concealcursor = "nvic"

        local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
        local cursor_line = vim.api.nvim_win_get_cursor(0)[1]
        local in_code = false

        for i, line in ipairs(lines) do
          local function hide_line()
            if i == cursor_line then return end 
            local mask = string.rep(" ", vim.fn.strdisplaywidth(line))
            vim.api.nvim_buf_set_extmark(buf, ns_cell, i - 1, 0, {
              virt_text = { { mask, "Conceal" } },
              virt_text_pos = "overlay", priority = 9000,
            })
          end

          -- 1. SECTIONS MARKDOWN / HEADERS
          if line:match("^#+ ") or line:match("<!-- #region") or line:match("#region") then
            hide_line()
            local title = line:gsub("^#+%s*", ""):gsub("<!%-%-%s*", ""):gsub("%s*%-%->", "")
            title = title ~= "" and title:upper() or "SECTION"
            vim.api.nvim_buf_set_extmark(buf, ns_cell, i - 1, 0, {
              virt_lines = { { 
                { "📝 ╔══ # " .. title .. " ", "JupyterMdHeader" },
                { string.rep("═", math.max(65 - #title, 5)), "JupyterMdHeader" },
                { "╗", "JupyterMdHeader" }
              } },
              virt_lines_above = true, priority = 8900 })
          elseif line:match("<!-- #endregion") or line:match("#endregion") then
            hide_line()
            vim.api.nvim_buf_set_extmark(buf, ns_cell, i - 1, 0, {
              virt_lines = { { 
                { "   ╚" .. string.rep("═", 5), "JupyterFooter" },
                { " FIN SECTION ", "JupyterFooter" }, 
                { string.rep("═", 54), "JupyterFooter" },
                { "╝", "JupyterFooter" }
              } },
              virt_lines_above = false, priority = 8900 })
          
          -- 2. BLOCS DE CODE (Standard / Magics / VSCode)
          elseif line:match("^%s*```") or line:match("^%%%%%w+") then
            hide_line()
            if not in_code then
              local lang = line:match('languageId": "([^"]+)"') 
                           or line:match("^%s*```(%w+)") 
                           or line:match("^%%%%(%w+)") 
                           or "Python"
              lang = lang:gsub("^%w", string.upper)
              
              vim.api.nvim_buf_set_extmark(buf, ns_cell, i - 1, 0, {
                virt_lines = { { 
                  { "⚡ ╔══ [ " .. lang .. " ] ", "JupyterCodeHeader" },
                  { string.rep("═", 55), "JupyterCodeHeader" },
                  { "╗", "JupyterCodeHeader" }
                } },
                virt_lines_above = true, priority = 8900 })
              in_code = true
            else
              vim.api.nvim_buf_set_extmark(buf, ns_cell, i - 1, 0, {
                virt_lines = { { 
                  { "   ╚" .. string.rep("═", 5), "JupyterFooter" },
                  { " FIN CELLULE CODE ", "JupyterFooter" },
                  { string.rep("═", 50), "JupyterFooter" },
                  { "╝", "JupyterFooter" }
                } },
                virt_lines_above = false, priority = 8900 })
              in_code = false
            end
          end
        end
      end

      -- ⚡ TRIGGERS
      vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter", "BufWritePost", "CursorMoved", "TextChanged" }, {
        pattern = "*",
        callback = function(ev)
          local name = vim.api.nvim_buf_get_name(ev.buf)
          if name:match("%.ipynb") or name:match("%.md") then
            vim.defer_fn(function() if vim.api.nvim_buf_is_valid(ev.buf) then do_decorate(ev.buf) end end, 20)
          end
        end,
      })

      -- 🔄 COMMANDES
      vim.api.nvim_create_user_command("JDecor", function() do_decorate() end, {})
      vim.api.nvim_create_user_command("JSync", function()
        local path = vim.api.nvim_buf_get_name(0)
        if path:match("%.md$") then
          local ipynb = path:gsub("%.md$", ".ipynb")
          vim.fn.system({ "jupytext", "--update", "--set-kernel", "python3_nvim", "--to", "ipynb", path })
          vim.notify("🔄 IPYNB Synchronisé : " .. vim.fn.fnamemodify(ipynb, ":t"), vim.log.levels.INFO)
        end
      end, {})

      vim.api.nvim_create_autocmd("BufWritePost", {
        pattern = "*.md",
        callback = function() vim.cmd("JSync") end,
      })

      vim.keymap.set("n", "<leader>jd", "<cmd>JDecor<cr>", { desc = "Rafraîchir les Cadres" })
      vim.keymap.set("n", "<leader>js", "<cmd>JSync<cr>", { desc = "Sync Automatique IPYNB" })
    end,
  },
}
