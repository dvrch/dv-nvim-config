-- This file is for custom keymaps
-- You can create new keymaps here

-- Open the default LazyVim dashboard
-- Shortcut <leader>db
vim.keymap.set("n", "<leader>db", ":Alpha<CR>", { desc = "Open Dashboard" })

-- Open a terminal
vim.keymap.set("n", "<leader>t", ":terminal<CR>", { desc = "Open Terminal" })

-- Toggle Gemini auto-launch
vim.keymap.set("n", "<leader>gT", function()
  vim.g.gemini_autolaunch = not vim.g.gemini_autolaunch
  local status = vim.g.gemini_autolaunch and "ACTIVÉ" or "DÉSACTIVÉ"
  vim.notify("🤖 Gemini auto-launch: " .. status, vim.log.levels.INFO)
end, { desc = "Toggle Gemini Auto-Launch" })

-- Open Gemini CLI manually (leader gc)
vim.keymap.set("n", "<leader>gc", ":tabnew | terminal gemini<CR>", { desc = "Open Gemini CLI" })

-- Open current file in VSCode (leader ov)
vim.keymap.set("n", "<leader>ov", function()
  local file_path = vim.fn.expand("%:p")
  if file_path and file_path ~= "" then
    vim.fn.jobstart({ "code", file_path }, { detach = true })
    vim.notify("📝 VSCode: " .. vim.fn.pathshorten(file_path), vim.log.levels.INFO)
  else
    vim.notify("Aucun fichier à ouvrir.", vim.log.levels.WARN)
  end
end, { desc = "Open in VSCode" })

-- Open current file in Zed (leader oz)
vim.keymap.set("n", "<leader>oz", function()
  local file_path = vim.fn.expand("%:p")
  if file_path and file_path ~= "" then
    -- Chemin exact récupéré de l'image (Propriétés de l'application)
    local zed_path = "/home/kd/.local/zed.app/bin/zed"
    vim.fn.jobstart({ zed_path, file_path }, { detach = true })
    vim.notify("⚡ Zed: " .. vim.fn.pathshorten(file_path), vim.log.levels.INFO)
  else
    vim.notify("Aucun fichier à ouvrir.", vim.log.levels.WARN)
  end
end, { desc = "Open in Zed" })

-- Locate current file in explorer
vim.keymap.set("n", "<leader>oe", function()
  local file = vim.fn.expand("%:p")
  if file and file ~= "" then
    -- Use os.execute with nohup to ensure it detaches correctly
    local cmd = string.format("nohup /usr/bin/dolphin --select %s >/dev/null 2>&1 &", vim.fn.shellescape(file))
    os.execute(cmd)
    vim.notify("Dolphin (Focus) : " .. vim.fn.pathshorten(file), vim.log.levels.INFO)
  end
end, { desc = "Locate in Dolphin Explorer" })

-- Open current directory in explorer
vim.keymap.set("n", "<leader>od", function()
  local dir = vim.fn.expand("%:p:h")
  if dir and dir ~= "" then
    local cmd = string.format("nohup /usr/bin/dolphin %s >/dev/null 2>&1 &", vim.fn.shellescape(dir))
    os.execute(cmd)
    vim.notify("Dolphin (Dossier) : " .. vim.fn.pathshorten(dir), vim.log.levels.INFO)
  end
end, { desc = "Open Directory in Dolphin" })

-- Open file under cursor with system default
vim.keymap.set("n", "<leader>ox", function()
  local file = vim.fn.expand("<cfile>")
  if file and file ~= "" then
    vim.fn.jobstart({ "xdg-open", file }, { detach = true })
  end
end, { desc = "Open with System Default" })

-- Find recent projects (workspaces) using telescope-frecency
-- Shortcut <leader>pw
vim.keymap.set("n", "<leader>pw", "<cmd>Telescope frecency workspace=CWD<CR>", { desc = "[P]roject [W]orkspaces (frecency)" })