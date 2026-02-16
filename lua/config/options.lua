-- Options globales (toujours chargées avant lazy.nvim)

vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" })
vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded" })

-- DÉSACTIVATION GLOBALE DES SWAPFILES (Solution radicale mais efficace)
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.undofile = true -- Garde l'undo history (c'est utile)

-- Protection supplémentaire pour les notebooks
vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
  pattern = "*.ipynb",
  callback = function()
    vim.opt_local.swapfile = false
    vim.opt_local.backup = false
    vim.opt_local.writebackup = false
    vim.b.swapfile_disabled = true -- Flag custom
  end,
})
