vim.g.python3_host_prog = "/usr/bin/python3"
package.path = package.path .. ";" .. vim.fn.stdpath("config") .. "/lua/?.lua"

-- Vérification et installation des dépendances au démarrage
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    require("utils.dependencies").ensure_all()
  end,
})

-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
vim.env.PATH = vim.env.PATH .. ":/home/dv/.nvm/versions/node/v24.5.0/bin"
vim.opt.clipboard:append("unnamedplus")
require("config.spell")
require("custom_syntax")
require("config.autocmds")

-- Fait en sorte que taper 'jj' rapidement quitte le mode Insertion
vim.keymap.set('i', 'jj', '<Esc>', {
  noremap = true,
  silent = true
})

-- Fait en sorte que taper 'jj' rapidement quitte le mode Terminal
vim.keymap.set('t', 'jj', '<C-\\><C-n>', {
  noremap = true,
  silent = true
})

vim.opt.termguicolors = true
