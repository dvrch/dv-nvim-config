return {
  {
    "iamcco/markdown-preview.nvim",
    enabled = false, -- Désactivation explicite
  },
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
      spec = {
        { "<leader>m", { name = "Mermaid", _ = "which_key_ignore" } },
      },
    },
  },
  {
    "nvim-lua/plenary.nvim",
    config = function()
      -- Configuration de la fonction de prévisualisation
      local function preview_mermaid()
        -- Trouver le bloc Mermaid sous le curseur
        local cursor_line = vim.api.nvim_win_get_cursor(0)[1]
        local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
        local in_mermaid = false
        local start_line = 0
        local diagram_lines = {}

        for i, line in ipairs(lines) do
          if line:match("^```mermaid") then
            in_mermaid = true
            start_line = i
          elseif line:match("^```$") and in_mermaid then
            if cursor_line >= start_line and cursor_line <= i then
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
        local cache_dir = vim.fn.expand("~/.cache/nvim/mermaid")
        vim.fn.mkdir(cache_dir, "p")
        local input_file = cache_dir .. "/temp.mmd"
        local output_file = cache_dir .. "/temp.png"

        -- Écrire le diagramme
        local f = io.open(input_file, "w")
        if not f then
          vim.notify("Erreur lors de la création du fichier temporaire", vim.log.levels.ERROR)
          return
        end
        f:write(table.concat(diagram_lines, "\n"))
        f:close()

        -- Créer le buffer et la fenêtre
        local buf = vim.api.nvim_create_buf(false, true)
        local width = math.floor(vim.o.columns * 0.8)
        local height = math.floor(vim.o.lines * 0.8)
        local win = vim.api.nvim_open_win(buf, true, {
          relative = "editor",
          width = width,
          height = height,
          col = math.floor((vim.o.columns - width) / 2),
          row = math.floor((vim.o.lines - height) / 2),
          style = "minimal",
          border = "rounded",
        })

        -- Configurer la fermeture
        vim.keymap.set(
          "n",
          "q",
          function()
            vim.api.nvim_win_close(win, true)
            os.remove(input_file)
            os.remove(output_file)
          end,
          { buffer = buf, silent = true }
        )

        -- Générer et afficher le diagramme
        vim.fn.jobstart(
          { "mmdc", "-i", input_file, "-o", output_file },
          {
            on_exit = function(_, code)
              if code == 0 then
                vim.fn.termopen(
                  string.format(
                    "kitty +kitten icat --transfer-mode=file --scale-up --place=%dx%d@0x0 %s && sleep 999999",
                    width,
                    height,
                    output_file
                  )
                )
              else
                vim.notify("Erreur: Installation de mermaid-cli requise\nnpm install -g @mermaid-js/mermaid-cli", vim.log.levels.ERROR)
              end
            end,
          }
        )
      end

      -- Mapper la touche
      vim.keymap.set("n", "<leader>mp", preview_mermaid, { desc = "Aperçu Mermaid (Kitty)" })
    end,
  },
}