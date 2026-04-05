return {
  -- 1. Molten: Exécution & Output (STABLE)
  {
    "benlubas/molten-nvim",
    event = { "BufRead *.ipynb", "BufNewFile *.ipynb" },
    build = ":UpdateRemotePlugins",
    init = function()
      vim.g.molten_auto_open_output = true
      vim.g.molten_virt_text_output = true
      vim.g.molten_output_win_max_height = 20
      vim.g.molten_image_provider = "image.nvim"
    end,
  },

  -- 2. Jupytext: Le Coeur du Pont (OPTIMISÉ & SÉCURISÉ)
  {
    "GCBallesteros/jupytext.nvim",
    event = { "BufReadPre *.ipynb", "BufNewFile *.ipynb" },
    lazy = false, 
    opts = { style = "markdown", output_extension = "md", force_ft = "markdown" },
    config = function(_, opts)
      require("jupytext").setup(opts)

      local ns_cell = vim.api.nvim_create_namespace("jupyter_ghost_lines")

      -- 🧼 NETTOYEUR DE MARQUEURS (Pour les couleurs, une seule fois au chargement)
      local function sanitize_buffer(buf)
        local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
        local changed = false
        for i, line in ipairs(lines) do
          local lang = line:match('languageId":%s*"([^"]+)"')
          if lang then
            lines[i] = "```" .. lang
            changed = true
          end
        end
        if changed then
          vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
          vim.cmd("silent! w") -- Sauvegarde le nettoyage
        end
      end

      -- 🎨 DÉCORATEUR 4x4 DYNAMIQUE
      function decorate_cells(buf)
        buf = (buf == 0 or buf == nil) and vim.api.nvim_get_current_buf() or buf
        if not vim.api.nvim_buf_is_valid(buf) then return end
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

      -- 🔄 AUTOMATISMES (SÉCURISÉS)
      vim.api.nvim_create_autocmd({ "BufWinEnter", "BufReadPost", "CursorMoved", "InsertLeave" }, {
        pattern = "*.ipynb",
        callback = function(ev)
          if ev.event == "BufReadPost" then 
            vim.defer_fn(function() sanitize_buffer(ev.buf) end, 100)
          end
          vim.defer_fn(function() 
            if vim.api.nvim_buf_is_valid(ev.buf) then decorate_cells(ev.buf) end 
          end, 20)
        end,
      })

      -- Nettoyage des sidecars APRÈS la session, pas pendant chaque save
      vim.api.nvim_create_autocmd("VimLeave", {
        callback = function()
          vim.fn.system("rm /home/kd/scripts/*.md /home/kd/scripts/*.py")
        end,
      })

      -- COMMANDES
      vim.api.nvim_create_user_command("JupyterToggleView", function()
        local cur = vim.g.jupytext_user_fmt or "markdown"
        local nxt = (cur == "markdown") and "py:percent" or "markdown"
        vim.g.jupytext_user_fmt = nxt
        require("jupytext").setup({ style = nxt, force_ft = (nxt == "markdown" and "markdown" or "python") })
        vim.cmd("e!")
      end, {})

      vim.keymap.set("n", "<leader>jv", "<cmd>JupyterToggleView<cr>", { desc = "Bascule MD/PY" })
    end,
  },
}
