return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "markdown", "markdown_inline", "mermaid" })
    end,
  },
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = { "mermaid-cli" },
    },
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
      local function preview_mermaid()
        -- Vérifier que les dépendances sont installées
        -- Chercher mmdc dans mason ou dans le PATH système
        local mason_bin = vim.fn.expand("$HOME/.local/share/nvim/mason/bin/mmdc")
        local mmdc_cmd = vim.fn.filereadable(mason_bin) == 1 and mason_bin or "mmdc"
        
        if vim.fn.executable(mmdc_cmd) == 0 then
          vim.notify("Installation de mermaid-cli via npm...", vim.log.levels.INFO)
          vim.fn.system("sudo npm install -g @mermaid-js/mermaid-cli")
          if vim.fn.executable("mmdc") == 0 then
            vim.notify("Échec de l'installation de mermaid-cli", vim.log.levels.ERROR)
            return
          end
          mmdc_cmd = "mmdc"
        end

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

        local cache_dir = vim.fn.expand("~/.cache/nvim/mermaid")
        vim.fn.mkdir(cache_dir, "p")
        local input_file = cache_dir .. "/diagram.mmd"
        local output_file = cache_dir .. "/diagram.png"

        local f = io.open(input_file, "w")
        if not f then return end
        f:write(table.concat(diagram_lines, "\n"))
        f:close()

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
          border = "rounded"
        })

        vim.keymap.set("n", "q", function()
          vim.api.nvim_win_close(win, true)
          os.remove(input_file)
          os.remove(output_file)
        end, { buffer = buf, silent = true })

        vim.fn.jobstart({mmdc_cmd, "-i", input_file, "-o", output_file}, {
          on_exit = function(_, code)
            if code == 0 then
              vim.fn.termopen(string.format(
                "kitty +kitten icat --transfer-mode=file --scale-up --place=%dx%d@0x0 %s && sleep infinity",
                width, height, output_file
              ))
            else
              vim.notify("Erreur lors de la génération du diagramme", vim.log.levels.ERROR)
            end
          end
        })
      end

      vim.keymap.set("n", "<leader>mp", preview_mermaid, { desc = "Aperçu Mermaid" })
    end,
  }
}