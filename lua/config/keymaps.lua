-- This file is for custom keymaps
-- You can create new keymaps here

-- Open the default LazyVim dashboard
-- Shortcut <leader>db
vim.keymap.set("n", "<leader>db", ":Alpha<CR>", { desc = "Open Dashboard" })

-- Open a terminal
vim.keymap.set("n", "<leader>t", ":terminal<CR>", { desc = "Open Terminal" })

-- Open a terminal and run gemini in a new tab to avoid buffer errors
-- Shortcut <leader>gc
vim.keymap.set("n", "<leader>gc", ":tabnew | terminal gemini<CR>", { desc = "Open Gemini CLI in New Tab" })

-- Open the current file in VSCode
-- Shortcut <leader>ov
vim.keymap.set("n", "<leader>ov", function()
  local file_path = vim.fn.expand("%:p")
  if file_path and file_path ~= "" then
    local cmd = { "code", file_path }
    vim.fn.jobstart(cmd, { detach = true })
    vim.notify("Ouverture dans VSCode: " .. vim.fn.pathshorten(file_path), vim.log.levels.INFO)
  else
    vim.notify("Aucun fichier à ouvrir dans VSCode.", vim.log.levels.WARN)
  end
end, { desc = "Ouvrir le fichier actuel dans VSCode" })

-- Locate current file in explorer
vim.keymap.set("n", "<leader>oe", function()
  local dir = vim.fn.expand("%:p:h")
  if dir and dir ~= "" then
    -- Explicitly use dolphin as requested by the user
    vim.fn.jobstart({ "dolphin", "--select", vim.fn.expand("%:p") }, { detach = true })
    vim.notify("Explorateur ouvert sur: " .. dir, vim.log.levels.INFO)
  end
end, { desc = "Locate in Dolphin Explorer" })

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