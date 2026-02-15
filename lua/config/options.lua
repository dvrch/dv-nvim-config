-- Options are automatically loaded before lazy.nvim startup
-- Add any additional options here

vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" })
vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded" })

-- Désactivation TOTALE des swapfiles, backups et writebackup pour les notebooks
vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
  pattern = "*.ipynb",
  callback = function()
    vim.opt_local.swapfile = false
    vim.opt_local.backup = false
    vim.opt_local.writebackup = false
    vim.opt_local.undofile = false -- Désactive aussi l'undo persistent
  end,
})
