return {
  -- 1. Molten: Exécution & Output
  {
    "benlubas/molten-nvim",
    event = { "BufRead *.ipynb", "BufNewFile *.ipynb" },
    build = ":UpdateRemotePlugins",
    init = function()
      vim.g.molten_auto_open_output = true
      vim.g.molten_virt_text_output = true
      vim.g.molten_output_win_max_height = 20
      vim.g.molten_wrap_output = true
      vim.g.molten_image_provider = "image.nvim"
    end,
  },

  -- 2. Jupytext: Le Coeur du Pont (FIXED CRASH & UNIVERSAL)
  {
    "GCBallesteros/jupytext.nvim",
    event = { "BufReadPre *.ipynb", "BufNewFile *.ipynb" },
    lazy = false, 
    opts = {
      style = "markdown",
      output_extension = "md",
      force_ft = "markdown",
    },
    config = function(_, opts)
      -- PROTECTION : On s'assure que jupytext ne crash pas sur les métadonnées nil
      local ok, jupy = pcall(require, "jupytext")
      if ok then jupy.setup(opts) end

      -- 🎨 DÉCORATEUR UNIVERSEL 4x4 (v2 : Multi-Langage & LaTeX)
      local ns_cell = vim.api.nvim_create_namespace("jupyter_ghost_lines")

      local function decorate_cells(buf)
        buf = buf or vim.api.nvim_get_current_buf()
        if not vim.api.nvim_buf_is_valid(buf) then return end
        vim.api.nvim_buf_clear_namespace(buf, ns_cell, 0, -1)
        
        vim.opt_local.conceallevel = 2
        vim.opt_local.concealcursor = "nvic"

        local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
        local cursor_line = vim.api.nvim_win_get_cursor(0)[1]

        local in_code_block = false

        for i, line in ipairs(lines) do
          local function hide_line()
            if i == cursor_line then return end 
            local mask = string.rep(" ", math.max(#line, 1))
            vim.api.nvim_buf_set_extmark(buf, ns_cell, i - 1, 0, {
              virt_text = { { mask, "Conceal" } },
              virt_text_pos = "overlay", priority = 2500,
            })
          end

          -- 1. MARKDOWN REGIONS
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

          -- 2. CODE BLOCKS (Multi-Langage & Metadata VSCode)
          elseif line:match("^%s*```") then
            hide_line()
            if not in_code_block then
              -- Détection fine du langage (Priorité Metadata VSCode si présente)
              local lang = line:match('languageId":%s*"([^"]+)"') or line:match("^%s*```(%w+)") or "Python"
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
        end
      end

      -- AUTOMATISMES
      vim.api.nvim_create_autocmd({ "BufWinEnter", "BufWritePost", "TextChanged", "InsertLeave", "CursorMoved" }, {
        pattern = "*.ipynb",
        callback = function(ev)
          vim.defer_fn(function() if vim.api.nvim_buf_is_valid(ev.buf) then decorate_cells(ev.buf) end end, 10)
        end,
      })

      -- Forçage Format MD au rechargement
      vim.api.nvim_create_autocmd("BufReadPre", {
        pattern = "*.ipynb",
        callback = function(ev)
          vim.b[ev.buf].jupytext_fmt = vim.g.jupytext_user_fmt or "markdown"
        end,
      })

      -- 🔄 SYNC INVERSE
      vim.api.nvim_create_autocmd("BufWritePost", {
        pattern = "*.md",
        callback = function(ev)
          local ipynb = ev.match:gsub("%.md$", ".ipynb")
          if vim.fn.filereadable(ipynb) == 1 then
            vim.fn.jobstart({ "jupytext", "--update", "--to", "ipynb", ev.match })
          end
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
