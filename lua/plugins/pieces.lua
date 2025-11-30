-- ~/.config/nvim/lua/plugins/pieces.lua
return {
  {
    "pieces-app/plugin_neovim",
    dependencies = {
      "kyazdani42/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
      "hrsh7th/nvim-cmp",
    },
    config = function()
      -- Test de connexion sur le BON port
      local handle = io.popen("curl -s http://localhost:39300/health 2>/dev/null || echo 'failed'")
      if handle then
        local result = handle:read("*a")
        handle:close()

        if result ~= "failed" then
          vim.notify("✅ Pieces OS found on port 39300!")
          -- Forcer le port via variable d'environnement
          vim.fn.setenv("PIECES_OS_PORT", "39300")
        else
          vim.notify("❌ Pieces OS not found on port 39300", vim.log.levels.ERROR)
        end
      end
    end,
    lazy = false,
  },
}
