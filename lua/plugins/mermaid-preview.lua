return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "markdown",
        "mermaid",
      },
    },
  },
  {
    "iamcco/markdown-preview.nvim",
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
    keys = {
      { "<leader>mp", function()
        -- Lire le contenu du buffer actuel
        local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
        local in_mermaid = false
        local diagram_lines = {}
        
        -- Extraire le diagramme Mermaid
        for _, line in ipairs(lines) do
          if line:match("^```mermaid") then
            in_mermaid = true
          elseif line:match("^```$") and in_mermaid then
            in_mermaid = false
          elseif in_mermaid then
            table.insert(diagram_lines, line)
          end
        end
        
        if #diagram_lines == 0 then
          vim.notify("Aucun diagramme Mermaid trouvé", vim.log.levels.ERROR)
          return
        end
        
        -- Créer un buffer temporaire pour le résultat
        local temp_buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_command("vsplit")
        vim.api.nvim_win_set_buf(0, temp_buf)
        vim.api.nvim_buf_set_option(temp_buf, "buftype", "nofile")
        vim.api.nvim_buf_set_option(temp_buf, "bufhidden", "wipe")
        
        -- Écrire le diagramme dans un fichier temporaire
        local tmp_file = os.tmpname()
        local f = io.open(tmp_file, "w")
        if f then
          f:write(table.concat(diagram_lines, "\n"))
          f:close()
          
          -- Envoyer à kroki.io
          vim.fn.jobstart({"curl", "-s", "--data-urlencode", "diagram@" .. tmp_file, "https://kroki.io/mermaid/svg"}, {
            stdout_buffered = true,
            on_stdout = function(_, data)
              if data then
                vim.api.nvim_buf_set_lines(temp_buf, 0, -1, false, data)
              end
            end,
            on_exit = function()
              os.remove(tmp_file)
            end
          })
        end
      end, desc = "Aperçu Mermaid (Buffer)" },
    },
  }
}