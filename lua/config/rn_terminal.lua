local M = {}

M.last_term_chan = nil

-- Enregistre le canal (channel_id) du dernier terminal ouvert
vim.api.nvim_create_autocmd("TermOpen", {
  pattern = "*",
  callback = function(args)
    M.last_term_chan = vim.b[args.buf].terminal_job_id
  end,
})

-- Fonction pour injecter une commande dans le dernier terminal connu
function M.inject(cmd)
  if M.last_term_chan then
    vim.api.nvim_chan_send(M.last_term_chan, cmd .. "\n")
    vim.notify("✅ Commande injectée dans le terminal actif.", vim.log.levels.INFO)
  else
    -- Fallback : Créer un terminal en bas si aucun n'existe
    vim.cmd("botright split")
    vim.fn.termopen(cmd)
    vim.cmd("startinsert")
  end
end

-- Fonction pour exécuter dans un nouvel onglet
function M.new_tab(cmd)
  vim.cmd("tabnew")
  vim.fn.termopen(cmd)
  vim.cmd("startinsert")
end

return M
