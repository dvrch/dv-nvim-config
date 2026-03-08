local M = {}

M.last_term_chan = nil

-- Enregistre le canal (channel_id) du dernier terminal ouvert
vim.api.nvim_create_autocmd("TermOpen", {
  pattern = "*",
  callback = function(args)
    M.last_term_chan = vim.b[args.buf].terminal_job_id
  end,
})

-- Fonction interne pour créer un terminal shell et y injecter la commande
local function create_shell_and_inject(cmd)
  local shell = vim.env.SHELL or "bash"
  local buf = vim.api.nvim_get_current_buf()
  local chan = vim.fn.termopen(shell)
  M.last_term_chan = chan
  -- Petit délai pour s'assurer que le shell est prêt avant d'écrire
  vim.defer_fn(function()
    if M.last_term_chan then
      vim.api.nvim_chan_send(M.last_term_chan, cmd .. "\n")
    end
  end, 100)
end

-- Fonction pour injecter une commande dans le dernier terminal connu
function M.inject(cmd)
  if M.last_term_chan then
    -- On vérifie si le canal est toujours valide (le processus shell tourne toujours)
    local is_valid = pcall(vim.api.nvim_chan_send, M.last_term_chan, cmd .. "\n")
    if is_valid then
      vim.notify("✅ Commande injectée dans le terminal actif.", vim.log.levels.INFO)
      return
    end
  end
  
  -- Fallback : Créer un terminal en bas si aucun n'existe ou s'il est mort
  vim.cmd("botright split")
  create_shell_and_inject(cmd)
  vim.cmd("startinsert")
end

-- Fonction pour exécuter dans un nouvel onglet
function M.new_tab(cmd)
  vim.cmd("tabnew")
  create_shell_and_inject(cmd)
  vim.cmd("startinsert")
end

return M
