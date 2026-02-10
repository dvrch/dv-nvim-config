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

      local function get_output_window(suffix)
        local buf_name = "Houdini" .. (suffix or "Output")
        local target_buf = nil
        
        -- Find existing buffer by name
        for _, b in ipairs(vim.api.nvim_list_bufs()) do
          if vim.api.nvim_buf_get_name(b):match(buf_name .. "$") then
            target_buf = b
            break
          end
        end

        if target_buf == nil or not vim.api.nvim_buf_is_valid(target_buf) then
          target_buf = vim.api.nvim_create_buf(false, true)
          vim.api.nvim_buf_set_name(target_buf, buf_name)
          vim.api.nvim_buf_set_option(target_buf, "buftype", "nofile")
        end

        -- Update the internal reference if it's the main output
        if suffix == nil or suffix == "Output" then
            output_buf = target_buf
        end

        -- Check if buffer is displayed in any window
        local target_win = nil
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          if vim.api.nvim_win_get_buf(win) == target_buf then
            target_win = win
            break
          end
        end

        if target_win == nil then
          vim.cmd("belowright 15split")
          target_win = vim.api.nvim_get_current_win()
          vim.api.nvim_win_set_buf(target_win, target_buf)
        end
        return target_buf, target_win
      end

      local function run_in_houdini(filepath, suffix)
        local buf, win = get_output_window(suffix)
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

      -- Clear commands (All specialized buffers)
      vim.keymap.set("n", "<leader>rc", function()
        for _, suffix in ipairs({ "Output", "NodeInfo", "Errors" }) do
          local buf_name = "Houdini" .. suffix
          for _, b in ipairs(vim.api.nvim_list_bufs()) do
            if vim.api.nvim_buf_get_name(b):match(buf_name .. "$") then
              vim.api.nvim_buf_set_lines(b, 0, -1, false, { "--- Cleared ---" })
            end
          end
        end
        vim.notify("Logs Houdini effacés 🧹", vim.log.levels.INFO)
      end, { desc = "Clear All Houdini Logs" })

      -- Run Current File
      vim.keymap.set("n", "<leader>rr", function()
        run_in_houdini(vim.fn.expand("%:p"))
      end, { desc = "Run in Houdini (Persistent Win)" })

      -- Simulation Reset (Master)
      vim.keymap.set("n", "<leader>rs", function()
        local script = "/home/kd/Documents/proudini/P26_1/scripts/python/hq.py"
        local cmd = "python3 " .. script .. " 'import hou; hou.session.PROUDINI_KART_STATE = {}; print(\"Simulation Reset ✅\")'"
        local handle = io.popen(cmd)
        local result = handle:read("*a")
        handle:close()
        vim.notify(result:gsub("\n", ""), vim.log.levels.INFO)
      end, { desc = "Houdini: Reset Simulation Data" })

      -- Run Node Info (Now correctly using Absolute Paths & Dedicated Buffer)
      vim.keymap.set("n", "<leader>ri", function()
        vim.ui.input({ prompt = "Path (Vide = Sélection / ALL = Liste tout): ", default = "" }, function(input)
          local script = "/home/kd/Documents/proudini/P26_1/scripts/python/node_db.py"
          local hq_script = "/home/kd/Documents/proudini/P26_1/scripts/python/hq.py"
          local base_cmd = "python3 " .. hq_script .. " "
          local cmd = ""
          
          if input == "ALL" then
            cmd = base_cmd .. "'import sys; sys.argv=[\"\",\"ALL\",\"\"]; exec(open(\"" .. script .. "\").read())'"
          elseif input == "" then
            cmd = base_cmd .. "'import sys; sys.argv=[\"\",\"info\",\"\"]; exec(open(\"" .. script .. "\").read())'"
          else
            cmd = base_cmd .. "'import sys; sys.argv=[\"\",\"info\",\"" .. input .. "\"]; exec(open(\"" .. script .. "\").read())'"
          end
          
          local handle = io.popen(cmd .. " 2>&1")
          local result = handle:read("*a")
          handle:close()
          
          if not result or result == "" then
            result = "⚠️ Aucune réponse du serveur Houdini. Est-il lancé ?"
          end
          
          local buf, win = get_output_window("NodeInfo")
          -- On AJOUTE au lieu de remplacer
          vim.api.nvim_buf_set_lines(buf, -1, -1, false, { os.date("[%H:%M:%S] --- INFO ---") })
          vim.api.nvim_buf_set_lines(buf, -1, -1, false, vim.split(result, "\n"))
          vim.api.nvim_buf_set_lines(buf, -1, -1, false, { "--------------------", "" })
          vim.api.nvim_win_set_cursor(win, { vim.api.nvim_buf_line_count(buf), 0 })
        end)
      end, { desc = "Houdini: Node Database & Info (i)" })

      -- Run Full Parameters Report
      vim.keymap.set("n", "<leader>rp", function()
        local script = "/home/kd/Documents/proudini/P26_1/scripts/python/node_params_full.py"
        run_in_houdini(script, "Params")
      end, { desc = "Houdini: Full Parameters Report" })

      -- Run Error Report
      vim.keymap.set("n", "<leader>re", function()
        local script = "/home/kd/Documents/proudini/P26_1/scripts/python/houdini_errors.py"
        run_in_houdini(script, "Errors")
      end, { desc = "Houdini: Report Scene Errors" })
      
    end,
  },
}
