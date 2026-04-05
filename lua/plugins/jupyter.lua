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

      -- 🎨 PALETTE ELITE (Couleurs Vibrantes)
      vim.api.nvim_set_hl(0, "JupyterMdHeader", { fg = "#ffcc00", bold = true }) -- Jaune Gold
      vim.api.nvim_set_hl(0, "JupyterCodeHeader", { fg = "#ff6600", bold = true }) -- Orange Pur
      vim.api.nvim_set_hl(0, "JupyterFooter", { fg = "#555555", italic = true }) -- Gris discret

      local ns_cell = vim.api.nvim_create_namespace("jupyter_ghost_lines")

      -- 🎨 DÉCORATEUR ELITE V3.2 (Look Premium & Effectivité Maximale)
      function do_decorate(buf)
        buf = (buf == 0 or buf == nil) and vim.api.nvim_get_current_buf() or buf
        if not vim.api.nvim_buf_is_valid(buf) then return end
        
        local name = vim.api.nvim_buf_get_name(buf)
        local is_jupyter = name:match("%.ipynb") or name:match("%.md") or vim.b[buf].jupytext_fmt
        if not is_jupyter then return end

        vim.api.nvim_buf_clear_namespace(buf, ns_cell, 0, -1)
        
        vim.opt_local.conceallevel = 2
        vim.opt_local.concealcursor = "nvic"

        local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
        local cursor_line = vim.api.nvim_win_get_cursor(0)[1]
        local in_code = false

        for i, line in ipairs(lines) do
          -- Masquage Overlay (Adieu "Ghost lines")
          local function hide_line()
            if i == cursor_line then return end 
            local mask = string.rep(" ", vim.fn.strdisplaywidth(line))
            vim.api.nvim_buf_set_extmark(buf, ns_cell, i - 1, 0, {
              virt_text = { { mask, "Conceal" } },
              virt_text_pos = "overlay", priority = 5000,
            })
          end

          -- 1. SECTIONS MARKDOWN / HEADERS
          if line:match("^#+ ") or line:match("<!-- #region") or line:match("#region") then
            hide_line()
            local title = line:gsub("^#+%s*", ""):gsub("<!%-%-%s*", ""):gsub("%s*%-%->", "")
            title = title ~= "" and title:upper() or "MARKDOWN"
            vim.api.nvim_buf_set_extmark(buf, ns_cell, i - 1, 0, {
              virt_lines = { { 
                { "📝 ╔══ # " .. title .. " ", "JupyterMdHeader" },
                { string.rep("═", math.max(60 - #title, 5)), "JupyterMdHeader" },
                { "╗", "JupyterMdHeader" }
              } },
              virt_lines_above = true, priority = 4900 })
          elseif line:match("<!-- #endregion") or line:match("#endregion") then
            hide_line()
            vim.api.nvim_buf_set_extmark(buf, ns_cell, i - 1, 0, {
              virt_lines = { { 
                { "   ╚" .. string.rep("═", 5), "JupyterFooter" },
                { " FIN SECTION ", "JupyterFooter" }, 
                { string.rep("═", 49), "JupyterFooter" },
                { "╝", "JupyterFooter" }
              } },
              virt_lines_above = false, priority = 4900 })
          
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
                  { string.rep("═", 50), "JupyterCodeHeader" },
                  { "╗", "JupyterCodeHeader" }
                } },
                virt_lines_above = true, priority = 4900 })
              in_code = true
            else
              vim.api.nvim_buf_set_extmark(buf, ns_cell, i - 1, 0, {
                virt_lines = { { 
                  { "   ╚" .. string.rep("═", 5), "JupyterFooter" },
                  { " FIN CELLULE CODE ", "JupyterFooter" },
                  { string.rep("═", 45), "JupyterFooter" },
                  { "╝", "JupyterFooter" }
                } },
                virt_lines_above = false, priority = 4900 })
              in_code = false
            end
          end
        end
      end

      -- ⚡ TRIGGERS (Auto-Refresh)
      vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter", "BufWritePost", "CursorMoved", "ModeChanged", "TextChanged" }, {
        pattern = "*",
        callback = function(ev)
          local name = vim.api.nvim_buf_get_name(ev.buf)
          if name:match("%.ipynb") or name:match("%.md") then
            vim.defer_fn(function() if vim.api.nvim_buf_is_valid(ev.buf) then do_decorate(ev.buf) end end, 20)
          end
        end,
      })

      -- 🔄 COMMANDES & SYNC
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
