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