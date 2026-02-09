return {
  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        { "<leader>r", group = "run/houdini" },
      },
    },
  },
  {
    "stevearc/overseer.nvim",
    opts = {},
    config = function()
      local output_buf = nil
      local output_win = nil

      local function get_output_window()
        if output_buf == nil or not vim.api.nvim_buf_is_valid(output_buf) then
          output_buf = vim.api.nvim_create_buf(false, true)
          vim.api.nvim_buf_set_name(output_buf, "HoudiniOutput")
          vim.api.nvim_buf_set_option(output_buf, "buftype", "nofile")
        end

        -- Check if buffer is displayed in any window
        local wins = vim.api.nvim_list_wins()
        output_win = nil
        for _, win in ipairs(wins) do
          if vim.api.nvim_win_get_buf(win) == output_buf then
            output_win = win
            break
          end
        end

        if output_win == nil then
          vim.cmd("belowright 15split")
          output_win = vim.api.nvim_get_current_win()
          vim.api.nvim_win_set_buf(output_win, output_buf)
        end
        return output_buf, output_win
      end

      local function run_in_houdini(filepath)
        local buf, win = get_output_window()
        local cmd = { "python3", "/home/kd/Documents/proudini/P26_1/scripts/python/send_to_houdini.py", filepath }
        
        vim.api.nvim_buf_set_lines(buf, -1, -1, false, { "🚀 Executing: " .. filepath .. " [" .. os.date("%H:%M:%S") .. "]" })

        vim.fn.jobstart(cmd, {
          stdout_buffered = false,
          on_stdout = function(_, data)
            if data then
              vim.api.nvim_buf_set_lines(buf, -1, -1, false, data)
              vim.api.nvim_win_set_cursor(win, { vim.api.nvim_buf_line_count(buf), 0 })
            end
          end,
          on_stderr = function(_, data)
            if data then
              vim.api.nvim_buf_set_lines(buf, -1, -1, false, data)
            end
          end,
          on_exit = function(_, code)
            vim.api.nvim_buf_set_lines(buf, -1, -1, false, { "🏁 Finished with code " .. code, "--------------------" })
          end,
        })
      end

      -- Clear command
      vim.keymap.set("n", "<leader>rc", function()
        if output_buf and vim.api.nvim_buf_is_valid(output_buf) then
          vim.api.nvim_buf_set_lines(output_buf, 0, -1, false, { "--- Cleared ---" })
        end
      end, { desc = "Clear Houdini Output" })

      -- Run Current File
      vim.keymap.set("n", "<leader>rr", function()
        run_in_houdini(vim.fn.expand("%:p"))
      end, { desc = "Run in Houdini (Persistent Win)" })

      -- Run Node Info
      vim.keymap.set("n", "<leader>ri", function()
        vim.ui.input({ prompt = "Node Path (Laissez vide pour la sélection Houdini): ", default = "" }, function(input)
          -- On passe l'input (qui peut être vide) au script
          local script = "/home/kd/Documents/proudini/P26_1/scripts/python/node_info.py"
          local tmp_cmd = "python3 " .. script .. " '" .. (input or "") .. "'"
          
          local handle = io.popen(tmp_cmd)
          local result = handle:read("*a")
          handle:close()
          
          local buf, win = get_output_window()
          vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(result, "\n"))
        end)
      end, { desc = "Houdini: Get Node Info (i)" })

      -- Run Error Report
      vim.keymap.set("n", "<leader>re", function()
        local script = "/home/kd/Documents/proudini/P26_1/scripts/python/houdini_errors.py"
        run_in_houdini(script)
      end, { desc = "Houdini: Report Scene Errors" })
      
    end,
  },
}
