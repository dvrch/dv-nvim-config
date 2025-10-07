return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, { "markdown", "mermaid" })
      end
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
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = function()
      vim.fn["mkdp#util#install"]()
    end,
    init = function()
      vim.g.mkdp_filetypes = { "markdown" }
      vim.g.mkdp_auto_start = 0
      vim.g.mkdp_open_to_the_world = 0
      vim.g.mkdp_open_ip = "127.0.0.1"
      vim.g.mkdp_port = "8888"
      vim.g.mkdp_echo_preview_url = true
      vim.g.mkdp_preview_options = {
        mermaid = { theme = "default" }
      }
      vim.g.mkdp_markdown_css = vim.fn.expand("~/.config/nvim/colors/markdown.css")
      vim.g.mkdp_page_title = "${name}"
      vim.g.mkdp_preview_options.disable_sync_scroll = 1
    end,
    config = function()
      vim.keymap.set("n", "<leader>mp", function()
        -- Extraire le contenu Mermaid sous le curseur
        local cursor_pos = vim.api.nvim_win_get_cursor(0)
        local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
        local in_mermaid = false
        local start_line = 0
        local diagram_lines = {}
        
        -- Chercher le bloc Mermaid autour du curseur
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
        local output_file = tmp_dir .. "/diagram.svg"

        -- Sauvegarder le diagramme
        local f = io.open(input_file, "w")
        if not f then return end
        f:write(table.concat(diagram_lines, "\n"))
        f:close()

        -- Créer une fenêtre flottante
        local buf = vim.api.nvim_create_buf(false, true)
        local width = math.floor(vim.o.columns * 0.8)
        local height = math.floor(vim.o.lines * 0.8)
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
        vim.api.nvim_buf_set_keymap(buf, "n", "q", ":q<CR>", { noremap = true, silent = true })
        
        -- Lancer la conversion et l'affichage
        vim.fn.jobstart({"mmdc", "-i", input_file, "-o", output_file}, {
          on_exit = function(_, code)
            if code == 0 then
              vim.fn.termopen(string.format(
                "kitty +kitten icat --clear --transfer-mode=file --align=center --place=%dx%d@%dx%d %s",
                width, height, 0, 0, output_file
              ))
            else
              vim.notify("Erreur lors de la génération du diagramme", vim.log.levels.ERROR)
            end
          end
        })
      end, { desc = "Aperçu Mermaid (Kitty)" })
    },
  }
}