local M = {}

function M.show_help()
  local help_text = {
    "╔══════════════════════════════════════════════════════╗",
    "║                Aide pour le plugin Pieces              ║",
    "╚══════════════════════════════════════════════════════╝",
    "",
    "🤖 Copilote IA",
    "──────────────────",
    "  :PiecesCopilot         - Ouvre la fenêtre de chat.",
    "  :PiecesChats           - Affiche les conversations passées.",
    "",
    "✂️ Gestion des extraits",
    "────────────────────────",
    "  :PiecesCreateMaterial  - Sauvegarde le texte sélectionné.",
    "  :PiecesDrive           - Affiche tous vos extraits.",
    "",
    "👤 Gestion du compte",
    "───────────────────",
    "  :PiecesLogin           - Se connecter.",
    "  :PiecesLogout          - Se déconnecter.",
    "  :PiecesAccount         - Voir les infos du compte.",
    "  :PiecesConnectCloud    - Connecter au cloud personnel.",
    "",
    "✅ Diagnostic",
    "──────────────",
    "  :PiecesHealth          - Vérifie la connexion au service.",
    "",
    "Appuyez sur 'q' pour fermer cette fenêtre.",
  }

  -- Dimensions et position de la fenêtre
  local width = 80
  local height = #help_text + 2
  local top = math.floor((vim.o.lines - height) / 2)
  local left = math.floor((vim.o.columns - width) / 2)

  -- Création du buffer et de la fenêtre
  local buf = vim.api.nvim_create_buf(false, true)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    row = top,
    col = left,
    style = 'minimal',
    border = 'rounded',
  })

  -- Remplissage du buffer
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, help_text)
  vim.api.nvim_buf_set_option(buf, 'modifiable', false)

  -- Raccourci pour fermer la fenêtre
  vim.api.nvim_buf_set_keymap(buf, 'n', 'q', '<cmd>close<cr>', { noremap = true, silent = true })
end

-- Création de la commande utilisateur
vim.api.nvim_create_user_command('PiecesHelp', M.show_help, {
  desc = 'Affiche l\'aide pour le plugin Pieces'
})

return M
