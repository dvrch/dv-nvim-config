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
      vim.defer_fn(function()
        -- Vérifier si Pieces OS répond
        local handle = io.popen("curl -s http://localhost:5321/health 2>/dev/null || echo 'not_running'")
        if handle then
          local result = handle:read("*a")
          handle:close()

          if result ~= "not_running" and result ~= "" then
            vim.notify("✅ Pieces OS is running and responsive")
          else
            vim.notify("❌ Pieces OS not responding. Please start it with: pieces-os &", vim.log.levels.ERROR)
          end
        end
      end, 2000)
    end,
    lazy = false,
  },
}
