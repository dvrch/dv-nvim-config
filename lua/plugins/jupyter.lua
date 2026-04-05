return {
  -- 1. Molten: Exécution & Output
  {
    "benlubas/molten-nvim",
    event = { "BufRead *.ipynb", "BufNewFile *.ipynb", "BufRead *.md" },
    build = ":UpdateRemotePlugins",
    init = function()
      vim.g.molten_auto_open_output = true
      vim.g.molten_virt_text_output = true
      vim.g.molten_output_win_max_height = 20
      vim.g.molten_image_provider = "image.nvim"
    end,
  },

  -- 2. Jupytext (VERSION PURE MARKDOWN SUR IPYNB OU MD)
  {
    "GCBallesteros/jupytext.nvim",
    event = { "BufReadPre *.ipynb", "BufNewFile *.ipynb", "BufRead *.md" },
    lazy = false, 
    opts = { style = "markdown", output_extension = "md", force_ft = "markdown" },
    config = function(_, opts)
      require("jupytext").setup(opts)

      local ns_cell = vim.api.nvim_create_namespace("jupyter_ghost_lines")

      -- 🎨 DÉCORATEUR UNIVERSEL ELITE (MD & IPYNB)
      function do_decorate(buf)
        buf = (buf == 0 or buf == nil) and vim.api.nvim_get_current_buf() or buf
        if not vim.api.nvim_buf_is_valid(buf) then return end
        
        local name = vim.api.nvim_buf_get_name(buf)
        if not name:match("%.ipynb") and not name:match("%.md") then return end

        vim.api.nvim_buf_clear_namespace(buf, ns_cell, 0, -1)
        vim.opt_local.conceallevel = 2
        vim.opt_local.concealcursor = "nvic"

        local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
        local cursor_line = vim.api.nvim_win_get_cursor(0)[1]
        local in_code = false

        for i, line in ipairs(lines) do
          local function hide_line()
            if i == cursor_line then return end 
            local mask = string.rep(" ", math.max(#line, 1))
            vim.api.nvim_buf_set_extmark(buf, ns_cell, i - 1, 0, {
              virt_text = { { mask, "Conceal" } },
              virt_text_pos = "overlay", priority = 2500,
            })
          end

          -- 1. REGIONS & HEADERS (MARKDOWN)
          if line:match("<!-- #region") or line:match("#region") then
            hide_line()
            vim.api.nvim_buf_set_extmark(buf, ns_cell, i - 1, 0, {
              virt_lines = { { { "📝 ╔══ CELLULE MARKDOWN ══════════════════════════════════════════╗", "String" } } },
              virt_lines_above = true, priority = 2400 })
          elseif line:match("<!-- #endregion") or line:match("#endregion") then
            hide_line()
            vim.api.nvim_buf_set_extmark(buf, ns_cell, i - 1, 0, {
              virt_lines = { { { "   ╚══ FIN CELLULE ═══════════════════════════════════════════════╝", "Comment" } } },
              virt_lines_above = false, priority = 2400 })
          
          -- 2. BLOCS DE CODE (Standard ```lang)
          elseif line:match("^%s*```") then
            hide_line()
            if not in_code then
              local lang = line:match("^%s*```(%w+)") or "Python"
              vim.api.nvim_buf_set_extmark(buf, ns_cell, i - 1, 0, {
                virt_lines = { { { "⚡ ╔══ CELLULE CODE (" .. lang .. ") ════════════════════════════════", "Special" } } },
                virt_lines_above = true, priority = 2400 })
              in_code = true
            else
              vim.api.nvim_buf_set_extmark(buf, ns_cell, i - 1, 0, {
                virt_lines = { { { "   ╚══ FIN CELLULE CODE ══════════════════════════════════════════╝", "Comment" } } },
                virt_lines_above = false, priority = 2400 })
              in_code = false
            end
          end
        end
      end

      -- ⚡ TRIGGERS ULTRA-RÉACTIFS (MD & IPYNB)
      vim.api.nvim_create_autocmd({ "BufWinEnter", "BufReadPost", "BufWritePost", "CursorMoved", "WinEnter" }, {
        pattern = { "*.ipynb", "*.md" },
        callback = function(ev)
          vim.defer_fn(function() if vim.api.nvim_buf_is_valid(ev.buf) then do_decorate(ev.buf) end end, 20)
        end,
      })

      -- 🔄 COMMANDES & RACCOURCIS
      vim.api.nvim_create_user_command("JDecor", function() do_decorate() end, {})
      vim.api.nvim_create_user_command("JSync", function()
        local path = vim.api.nvim_buf_get_name(0)
        if path:match("%.md$") then
          local ipynb = path:gsub("%.md$", ".ipynb")
          vim.fn.system({ "jupytext", "--update", "--to", "ipynb", path })
          vim.notify("🔄 IPYNB Synchronisé : " .. vim.fn.fnamemodify(ipynb, ":t"), vim.log.levels.INFO)
        end
      end, {})

      -- Sync Auto lors du Save du MD
      vim.api.nvim_create_autocmd("BufWritePost", {
        pattern = "*.md",
        callback = function() vim.cmd("JSync") end,
      })

      vim.keymap.set("n", "<leader>ms", "<cmd>JSource<cr>", { desc = "Ouvrir Source Markdown" })
      vim.api.nvim_create_user_command("JSource", function()
        local path = vim.api.nvim_buf_get_name(0)
        if path:match("%.ipynb$") then
          local md = path:gsub("%.ipynb$", ".md")
          vim.cmd("e " .. md)
        end
      end, {})
    end,
  },
}
