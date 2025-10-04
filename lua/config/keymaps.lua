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