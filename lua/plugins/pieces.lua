-- ~/.config/nvim/lua/plugins/pieces.lua
return {
  {
    "pieces-app/plugin_neovim",
    init = function()
      -- Définir la variable AVANT le chargement du plugin
      vim.fn.setenv("PIECES_OS_PORT", "39300")
    end,
    config = function()
      vim.notify("Pieces OS configured for port 39300")

      -- Test de connexion
      vim.defer_fn(function()
        local handle = io.popen("curl -s http://localhost:39300/health 2>/dev/null | head -c 100")
        if handle then
          local result = handle:read("*a")
          handle:close()
          if result and result ~= "" then
            vim.notify("✅ Connected to Pieces OS on port 39300")
          else
            vim.notify("❌ Cannot connect to Pieces OS on port 39300")
          end
        end
      end, 2000)
    end,
    lazy = false,
  },
}
