return {

  {
    "mason-org/mason.nvim",
    cmd = "Mason",
    keys = {
      { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" },
    },
    build = ":MasonUpdate",
    opts = {
      ensure_installed = {},
      registries = {
        "github:mason-org/mason-registry",
      },
    },
  },
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    init = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 300
    end,
    opts = {
      spec = {
        { "<leader>m", group = "mermaid" },
      },
    },
  },
  {
    "nvim-lua/plenary.nvim",
    config = function()
      local function preview_mermaid()
        local mmdc = vim.fn.executable("mmdc") == 1 and "mmdc" or nil
        if not mmdc then
          vim.notify("mermaid-cli non trouvé, installation...", vim.log.levels.INFO)
          require("utils.dependencies").ensure_all()
          return
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

        vim.fn.jobstart({mmdc, "-i", input_file, "-o", output_file, "-b", "transparent"}, {
          on_exit = function(_, code)
            vim.schedule(function()
              if code == 0 then
                -- Run viu and capture its output to place it in the floating window buffer
                vim.fn.jobstart({"/home/kd/.cargo/bin/viu", "-w", tostring(width - 2), "-h", tostring(height - 2), output_file}, {
                  on_stdout = function(_, data)
                    if data then
                      vim.api.nvim_buf_set_lines(buf, -1, -1, false, data)
                    end
                  end,
                  on_exit = function()
                    os.remove(input_file)
                    os.remove(output_file)
                  end,
                })
              else
                vim.api.nvim_win_close(win, true)
                vim.notify("Erreur lors de la génération du diagramme Mermaid.", vim.log.levels.ERROR)
              end
            end)
          end,
        })
      end

      vim.keymap.set("n", "<leader>mp", preview_mermaid, { desc = "Aperçu Mermaid" })
    end,
  }
}