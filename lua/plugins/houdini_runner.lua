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
    event = { "User LoadHeavy" },
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
        local cmd = { "python3", "/home/kd/scripts/proudini_core/python/send_to_houdini.py", filepath }
        
        if vim.g.proudini_port ~= nil then
            table.insert(cmd, tostring(vim.g.proudini_port))
        end

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

      -- Select Houdini Target Instance dynamically
      vim.keymap.set("n", "<leader>rc", function()
        local script = "/home/kd/scripts/proudini_core/python/get_houdini_instances.py"
        local handle = io.popen("python3 " .. script)
        local result = handle:read("*a")
        handle:close()

        if result == "" or result == "[]\n" then
            vim.notify("Aucune instance Houdini (Python Socket) trouvée ❌", vim.log.levels.ERROR)
            return
        end

        local ok, instances = pcall(vim.fn.json_decode, result)
        if not ok or not instances then
            vim.notify("Crash de l'API de sélection ❌", vim.log.levels.ERROR)
            return
        end

        local options = {}
        for _, inst in ipairs(instances) do
            table.insert(options, string.format("Port %s : %s", inst.port, inst.project))
        end

        vim.ui.select(options, { prompt = "🎯 Choisir la cible Houdini :" }, function(choice, idx)
            if choice then
                vim.g.proudini_port = instances[idx].port
                vim.notify("Cible verrouillée sur " .. choice .. " ✅", vim.log.levels.INFO)
            end
        end)
      end, { desc = "Houdini: Select Target Instance" })

      local function run_live_logs()
        local buf, win = get_output_window("LiveLog")
        local log_file = "/tmp/houdini_live.log"
        
        -- S'assurer que le fichier existe
        os.execute("touch " .. log_file)
        
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "📺 SUIVI DES LOGS LIVE HOUDINI...", "---" })
        
        vim.fn.jobstart({ "tail", "-f", log_file }, {
          on_stdout = function(_, data)
            if data then
              vim.api.nvim_buf_set_lines(buf, -1, -1, false, data)
              vim.api.nvim_win_set_cursor(win, { vim.api.nvim_buf_line_count(buf), 0 })
            end
          end,
        })
      end

      local function open_houdini_shell()
        -- 🛰️ RÉCUPÉRATION DES INSTANCES
        local script = "/home/kd/scripts/proudini_core/python/get_houdini_instances.py"
        local handle = io.popen("python3 " .. script)
        local result = handle:read("*a")
        handle:close()

        if result == "" or result == "[]\n" then
            vim.notify("Aucune instance Houdini trouvée pour le terminal ❌", vim.log.levels.ERROR)
            return
        end

        local ok, instances = pcall(vim.fn.json_decode, result)
        if not ok or not instances then return end

        local options = {}
        for _, inst in ipairs(instances) do
            table.insert(options, string.format("REPL Port %s : %s", inst.port, inst.project))
        end

        vim.ui.select(options, { prompt = "🎯 Ouvrir un terminal pour :" }, function(choice, idx)
            if not choice then return end
            
            local port = instances[idx].port
            local buf_name = "HoudiniRepl:" .. port
            
            -- Vérifier si le terminal existe déjà
            for _, b in ipairs(vim.api.nvim_list_bufs()) do
              local bname = vim.api.nvim_buf_get_name(b)
              if bname:match(buf_name .. "$") then
                vim.notify("Focus sur le Terminal Port " .. port .. " 📺", vim.log.levels.INFO)
                vim.cmd("split") -- Ouvrir une fenêtre
                vim.api.nvim_win_set_buf(0, b)
                return
              end
            end

            -- Sinon, créer un nouveau terminal lié au port
            local hq_repl = "python3 /home/kd/scripts/proudini_core/python/hq.py repl -p " .. port
            vim.cmd("belowright 15split")
            local buf = vim.api.nvim_create_buf(false, true)
            vim.api.nvim_buf_set_name(buf, buf_name)
            vim.api.nvim_win_set_buf(0, buf)
            
            vim.schedule(function()
                vim.fn.termopen(hq_repl)
                vim.bo[buf].filetype = "python" -- 🎨 Force la couleur Python
                vim.cmd("startinsert") 
            end)
        end)
      end

      -- Clear commands (All specialized buffers)
      vim.keymap.set("n", "<leader>rk", function()
        for _, suffix in ipairs({ "Output", "NodeInfo", "Errors" }) do
          local buf_name = "Houdini" .. suffix
          for _, b in ipairs(vim.api.nvim_list_bufs()) do
            if vim.api.nvim_buf_get_name(b):match(buf_name .. "$") then
              vim.api.nvim_buf_set_lines(b, 0, -1, false, { "--- Cleared ---" })
            end
          end
        end
        vim.notify("Logs Houdini effacés 🧹", vim.log.levels.INFO)
      end, { desc = "Houdini: Clear All Logs" })

      -- Run Current File
      vim.keymap.set("n", "<leader>rr", function()
        run_in_houdini(vim.fn.expand("%:p"))
      end, { desc = "Run in Houdini (Persistent Win)" })

      -- Simulation Reset (Master)
      vim.keymap.set("n", "<leader>rs", function()
        local script = "/home/kd/scripts/proudini_core/python/hq.py"
        local cmd = "python3 " .. script .. " 'import hou; hou.session.PROUDINI_KART_STATE = {}; print(\"Simulation Reset ✅\")'"
        local handle = io.popen(cmd)
        local result = handle:read("*a")
        handle:close()
        vim.notify(result:gsub("\n", ""), vim.log.levels.INFO)
      end, { desc = "Houdini: Reset Simulation Data" })

      -- Run Node Info (Now using the dynamic port and selection-first logic)
      vim.keymap.set("n", "<leader>ri", function()
          local hq_script = "/home/kd/scripts/proudini_core/python/hq.py"
          local node_db = "/home/kd/scripts/proudini_core/python/node_db.py"
          
          -- We call 'hq' with our python logic directly
          local cmd = "python3 " .. hq_script .. " 'import sys; sys.argv=[\"\",\"info\",\"\"]; exec(open(\"" .. node_db .. "\").read())' 2>&1"
          
          -- Add custom port if locked
          if vim.g.proudini_port ~= nil then
             cmd = "python3 " .. hq_script .. " -p " .. vim.g.proudini_port .. " 'import sys; sys.argv=[\"\",\"info\",\"\"]; exec(open(\"" .. node_db .. "\").read())' 2>&1"
          end

          local handle = io.popen(cmd)
          local result = handle:read("*a")
          handle:close()
          
          if not result or result == "" or result:match("Aucun node sélectionné") then
            -- Si rien n'est sélectionné, ALORS on demande le chemin
            vim.ui.input({ prompt = "Node Path (ex: /obj/geo1 ou 'ALL'): ", default = "" }, function(input)
                if not input or input == "" then return end
                local query_cmd = ""
                if input == "ALL" then
                    query_cmd = "python3 " .. hq_script .. " 'import sys; sys.argv=[\"\",\"ALL\",\"\"]; exec(open(\"" .. node_db .. "\").read())' 2>&1"
                else
                    query_cmd = "python3 " .. hq_script .. " 'import sys; sys.argv=[\"\",\"info\",\"" .. input .. "\"]; exec(open(\"" .. node_db .. "\").read())' 2>&1"
                end
                
                local h = io.popen(query_cmd)
                local r = h:read("*a")
                h:close()
                
                local b, w = get_output_window("NodeInfo")
                vim.api.nvim_buf_set_lines(b, -1, -1, false, vim.split(r or "Empty", "\n"))
                vim.api.nvim_win_set_cursor(w, { vim.api.nvim_buf_line_count(b), 0 })
            end)
          else
            local buf, win = get_output_window("NodeInfo")
            vim.api.nvim_buf_set_lines(buf, -1, -1, false, { os.date("[%H:%M:%S] --- AUTO SELECTED INFO ---") })
            vim.api.nvim_buf_set_lines(buf, -1, -1, false, vim.split(result, "\n"))
            vim.api.nvim_win_set_cursor(win, { vim.api.nvim_buf_line_count(buf), 0 })
          end
      end, { desc = "Houdini: Instant Node Info (Selected or Path)" })

      -- Run Full Parameters Report
      vim.keymap.set("n", "<leader>rp", function()
        local script = "/home/kd/scripts/proudini_core/python/node_params_full.py"
        run_in_houdini(script, "Params")
      end, { desc = "Houdini: Full Parameters Report" })

      -- Run Error Report
      vim.keymap.set("n", "<leader>re", function()
        local script = "/home/kd/scripts/proudini_core/python/houdini_errors.py"
        run_in_houdini(script, "Errors")
      end, { desc = "Houdini: Report Scene Errors" })

      -- Interactive Shell
      vim.keymap.set("n", "<leader>rh", open_houdini_shell, { desc = "Houdini: Open Interactive Hython Shell" })

      -- Live Logs
      vim.keymap.set("n", "<leader>rw", run_live_logs, { desc = "Houdini: Watch Live Logs (tail -f)" })

      -- Start Live Logger in Houdini
      vim.keymap.set("n", "<leader>rx", function()
        local script = "/home/kd/scripts/proudini_core/python/live_logger.py"
        run_in_houdini(script)
        vim.notify("Live Logger démarré dans Houdini 🛰️", vim.log.levels.INFO)
      end, { desc = "Houdini: Start Live Logger" })

      -- Restart Houdini Server (In-process)
      vim.keymap.set("n", "<leader>rj", function()
        local script = "/home/kd/scripts/proudini_core/python/houdini_server.py"
        run_in_houdini("exec(open('" .. script .. "').read(), globals())")
        vim.notify("Serveur Houdini RECHARGÉ 📡", vim.log.levels.INFO)
      end, { desc = "Houdini: Restart Proudini Server" })

    end,
  },
}
