local M = {}

M.last_term_chan = nil

-- Enregistre le canal (channel_id) du dernier terminal ouvert
vim.api.nvim_create_autocmd("TermOpen", {
  pattern = "*",
  callback = function(args)
    M.last_term_chan = vim.b[args.buf].terminal_job_id
  end,
})

local function create_shell_and_inject(cmd)
  local shell = vim.o.shell or vim.env.SHELL or "bash"
  local buf = vim.api.nvim_get_current_buf()

  local is_pwsh = shell:match("pwsh$") or shell:match("powershell$")
  local chan
  if is_pwsh then
    chan = vim.fn.termopen({shell, "-NoLogo", "-NoExit", "-Command", cmd})
  else
    chan = vim.fn.termopen(shell)
  end
  M.last_term_chan = chan

  local short_cmd = cmd:sub(1, 15):gsub("[%s/:]", "_")
  local clean_name = "kr_[" .. short_cmd .. "]"
  pcall(vim.api.nvim_buf_set_name, buf, clean_name)

  if not is_pwsh then
    vim.defer_fn(function()
      if M.last_term_chan then
        vim.api.nvim_chan_send(M.last_term_chan, cmd .. "\n")
      end
    end, 100)
  end
end

-- Commande pour Extraire le buffer actuel et l'isoler dans une VRAIE nouvelle instance (v -n)
vim.api.nvim_create_user_command("ExtractInstance", function()
  local buf = vim.api.nvim_get_current_buf()
  local filepath = vim.api.nvim_buf_get_name(buf)
  
  if filepath:match("^term://") or filepath:match("^kr_%[") then
    vim.notify("❌ Impossible d'extraire un processus terminal. Extraire plutôt un vrai fichier.", vim.log.levels.WARN)
    return
  end
  
  if filepath == "" then
    vim.notify("❌ Ce buffer n'a pas de fichier associé (non sauvegardé).", vim.log.levels.ERROR)
    return
  end
  
  -- Lance V en forçant une nouvelle instance (-n) avec l'outil terminal actuel
  vim.fn.jobstart({ "kitty", "-1", "v", "-n", filepath }, { detach = true })
  vim.cmd("bdelete")
  vim.notify("🚀 Fichier détaché dans sa PROPRE instance indépendante !", vim.log.levels.INFO)
end, { desc = "Extrait (détache) le fichier courant dans un nouveau Neovim totalement isolé" })

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
