vim.g.python3_host_prog = "/home/kd/nvim-venv/bin/python"
package.path = package.path .. ";" .. vim.fn.stdpath("config") .. "/lua/?.lua"

-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
vim.env.PATH = vim.env.PATH .. ":/home/dv/.nvm/versions/node/v24.5.0/bin"
vim.opt.clipboard:append("unnamedplus")
require("config.spell")
require("custom_syntax")
require("config.autocmds")
require("pieces_help")

-- Fait en sorte que taper 'jj' rapidement quitte le mode Insertion
vim.keymap.set("i", "jj", "<Esc>", {
  noremap = true,
  silent = true,
})

-- Fait en sorte que taper 'jj' rapidement quitte le mode Terminal
vim.keymap.set("t", "jj", "<C-\\><C-n>", {
  noremap = true,
  silent = true,
})

vim.opt.termguicolors = true

-- Commandes personnalisées ajoutées par Gemini

-- Ouvre l'explorateur de fichiers dans le répertoire du fichier actuel
vim.api.nvim_create_user_command("Explorer", function()
  vim.fn.jobstart("xdg-open " .. vim.fn.expand("%:p:h"))
end, { desc = "Ouvre l'explorateur de fichiers pour le fichier actuel" })

-- Copie le chemin absolu du fichier actuel dans le presse-papiers
vim.api.nvim_create_user_command("CopyPath", function()
  local path = vim.fn.expand("%:p")
  vim.fn.setreg("+", path)
  vim.notify("Chemin copié: " .. path)
end, { desc = "Copie le chemin absolu du fichier actuel" })

vim.g.python3_host_prog = "/home/kd/.config/nvim/nvim-python-venv/bin/python"
