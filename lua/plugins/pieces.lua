return {
  name = "plugin_neovim",
  dir = vim.fn.stdpath("config") .. "/plugin_neovim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "kyazdani42/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
  },
  event = "VeryLazy", -- Chargement différé pour éviter les problèmes au démarrage
  build = function()
    vim.notify("Pieces: Build process started for local plugin...", vim.log.levels.INFO)
    -- Installer les paquets python nécessaires
    local install_cmd = "pip3 install --user --upgrade pynvim pieces_os_client"
    local result = vim.fn.system(install_cmd)
    if vim.v.shell_error ~= 0 then
      vim.notify("Pieces: Failed to install/upgrade python packages. Please check pip3.", vim.log.levels.ERROR)
      vim.notify("pip3 output: " .. result, vim.log.levels.INFO)
      return
    end
    vim.notify("Pieces: Python packages installed/updated successfully.", vim.log.levels.INFO)

    -- Mettre à jour les plugins distants
    vim.notify("Pieces: Running :UpdateRemotePlugins...", vim.log.levels.INFO)
    vim.cmd("UpdateRemotePlugins")
    vim.notify("Pieces: UpdateRemotePlugins command executed. You MUST restart Neovim now.", vim.log.levels.WARN)
  end,
  init = function()
    -- Créer une commande utilisateur pour lancer le health check
    vim.api.nvim_create_user_command("PiecesHealthCheck", function()
      -- S'assurer que le plugin est chargé avant d'appeler sa commande
      require("lazy").load({ plugins = { "plugin_neovim" } })
      vim.cmd("PiecesHealth")
    end, {
      desc = "Run Pieces health check",
    })
  end,
  config = function()
    -- La configuration se fait principalement via les commandes du plugin
  end,
}