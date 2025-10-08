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

        local current_dir = vim.fn.expand('%:p:h')
        local output_file = current_dir .. '/mermaid-preview.png'
        local cache_dir = vim.fn.expand("~/.cache/nvim/mermaid")
        vim.fn.mkdir(cache_dir, "p")
        local input_file = cache_dir .. "/diagram.mmd"

        local f = io.open(input_file, "w")
        if not f then return end
        f:write(table.concat(diagram_lines, "\n"))
        f:close()

        vim.notify("Génération de l'aperçu Mermaid...", vim.log.levels.INFO)

        vim.fn.jobstart({mmdc, "-i", input_file, "-o", output_file}, {
          on_exit = function(_, code)
            vim.schedule(function()
              if code == 0 then
                local png_path = vim.fn.expand('%:p:h') .. '/mermaid-preview.png'
                local original_win = vim.api.nvim_get_current_win()
                local png_win_id = nil

                -- Check if a window exists to the right
                if vim.fn.winnr() < vim.fn.winnr('
                  vim.cmd('wincmd l')
                  png_win_id = vim.api.nvim_get_current_win()
                  vim.cmd('edit ' .. png_path)
                else
                  vim.cmd('vsplit ' .. png_path)
                  png_win_id = vim.api.nvim_get_current_win()
                end

                -- Move focus back to the original window
                vim.api.nvim_set_current_win(original_win)

                -- Start a timer to close the PNG window and delete the file
                if png_win_id then
                  vim.defer_fn(function()
                    if vim.api.nvim_win_is_valid(png_win_id) then
                      vim.api.nvim_win_close(png_win_id, true) -- Force close
                      os.remove(png_path)
                    end
                  end, 7000) -- 7 seconds
                end
              else
                vim.notify("Erreur lors de la g\233n\233ration du diagramme Mermaid.", vim.log.levels.ERROR)
              end
              os.remove(input_file)
            end)
          end,
        })
      end

      vim.keymap.set("n", "<leader>mp", preview_mermaid, { desc = "Aperçu Mermaid" })
    end,
  }
}) then
                  vim.cmd('wincmd l')
                  png_win_id = vim.api.nvim_get_current_win()
                  vim.cmd('edit ' .. png_path)
                else
                  vim.cmd('vsplit ' .. png_path)
                  png_win_id = vim.api.nvim_get_current_win()
                end

                -- Move focus back to the original window
                vim.api.nvim_set_current_win(original_win)

                -- Start a timer to close the PNG window and delete the file
                if png_win_id then
                  vim.defer_fn(function()
                    if vim.api.nvim_win_is_valid(png_win_id) then
                      vim.api.nvim_win_close(png_win_id, true) -- Force close
                      os.remove(png_path)
                    end
                  end, 7000) -- 7 seconds
                end
              else
                vim.notify("Erreur lors de la g\233n\233ration du diagramme Mermaid.", vim.log.levels.ERROR)
              end
              os.remove(input_file)
            end)
          end,
        })
      end

      vim.keymap.set("n", "<leader>mp", preview_mermaid, { desc = "Aperçu Mermaid" })
    end,
  }
}