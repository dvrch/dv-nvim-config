-- Options globales (toujours chargées avant lazy.nvim)

vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" })
vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded" })

-- DÉSACTIVATION GLOBALE DES SWAPFILES (Solution radicale mais efficace)
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.undofile = true -- Garde l'undo history (c'est utile)

-- 🚀 AUTO-SAVE & LIVE SYNC GLOBAL
vim.opt.autowriteall = true -- Sauvegarde tout automatiquement
vim.opt.autoread = true -- Recharge les fichiers modifiés à l'extérieur (Houdini/Git)
vim.opt.updatetime = 300 -- Vitesse de réaction (300ms) pour CursorHold

-- On sauvegarde dès qu'on sort d'un buffer ou qu'on quitte le focus
vim.api.nvim_create_autocmd({ "FocusLost", "BufLeave", "BufWinLeave" }, {
  pattern = "*",
  callback = function()
    if vim.bo.modified and not vim.bo.readonly and vim.fn.expand("%") ~= "" then
      vim.cmd("silent! wall")
    end
  end,
})

-- On recharge tous les buffers quand on revient sur Neovim
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
  pattern = "*",
  callback = function()
    if vim.fn.getcmdwintype() == "" then
      vim.cmd("checktime")
    end
  end,
})

-- --- Configuration PowerShell pour Neovim ---
vim.opt.shell = "/usr/bin/zsh"
vim.opt.shellcmdflag = "-c"
vim.opt.shellredir = ">%%s 2>&1"
vim.opt.shellpipe = "2>&1 | tee %%s"
vim.opt.shellquote = ""
vim.opt.shellxquote = ""
vim.env.TERM = "xterm-256color"

-- Couleur de sélection visible en TTY (ANSI 4 = Blue)
vim.api.nvim_create_autocmd("ColorScheme", {
  callback = function()
    local visual = vim.api.nvim_get_hl(0, { name = "Visual" })
    vim.api.nvim_set_hl(0, "Visual", {
      bg = visual.bg,
      ctermbg = 4,
    })
  end,
})
