return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "markdown", "mermaid" })
    end,
  },
  {
    "folke/which-key.nvim",
    opts = {
      defaults = {
        ["<leader>m"] = { name = "Mermaid" },
      },
    },
  },
  {
    "nvim-lua/plenary.nvim",
    config = function()
      local function preview_mermaid()
        -- Extraire le bloc Mermaid sous le curseur
        local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
        local in_mermaid = false
        local start_line = 0
        local diagram_lines = {}
        local cursor_pos = vim.api.nvim_win_get_cursor(0)

        for i, line in ipairs(lines) do
          if line:match("^```mermaid") then
            in_mermaid = true
            start_line = i
          elseif line:match("^```$") and in_mermaid then
            if cursor_pos[1] >= start_line and cursor_pos[1] <= i then
              break
            end
            in_mermaid = false
            diagram_lines = {}
          elseif in_mermaid then
            table.insert(diagram_lines, line)
          end
        end

        if #diagram_lines == 0 then
          vim.notify("Placez le curseur dans un bloc Mermaid", vim.log.levels.WARN)
          return
        end

        -- Créer les fichiers temporaires
        local tmp_dir = vim.fn.expand("$HOME/.cache/nvim/mermaid")
        vim.fn.mkdir(tmp_dir, "p")
        local input_file = tmp_dir .. "/diagram.mmd"
        local output_file = tmp_dir .. "/diagram.png"

        -- Sauvegarder le diagramme
        local f = io.open(input_file, "w")
        if not f then return end
        f:write(table.concat(diagram_lines, "\n"))
        f:close()

        -- Créer une fenêtre flottante
        local width = math.floor(vim.o.columns * 0.8)
        local height = math.floor(vim.o.lines * 0.8)
        local buf = vim.api.nvim_create_buf(false, true)
        local opts = {
          relative = "editor",
          width = width,
          height = height,
          col = math.floor((vim.o.columns - width) / 2),
          row = math.floor((vim.o.lines - height) / 2),
          style = "minimal",
          border = "rounded"
        }

        local win = vim.api.nvim_open_win(buf, true, opts)
        vim.keymap.set("n", "q", ":q<CR>", { buffer = buf, silent = true })
        
        -- Générer le diagramme et l'afficher
        vim.fn.jobstart({"mmdc", "-i", input_file, "-o", output_file}, {
          on_exit = function(_, code)
            if code == 0 then
              vim.fn.termopen(string.format(
                "kitty +kitten icat --clear --transfer-mode=file --scale-up --place=%dx%d@%dx%d %s",
                width, height, 0, 0, output_file
              ), {
                on_exit = function()
                  os.remove(input_file)
                  os.remove(output_file)
                end
              })
            else
              vim.notify("Erreur lors de la génération du diagramme", vim.log.levels.ERROR)
            end
          end
        })
      end

      vim.keymap.set("n", "<leader>mp", preview_mermaid, { desc = "Aperçu Mermaid (Kitty)" })
    end,
  }
}