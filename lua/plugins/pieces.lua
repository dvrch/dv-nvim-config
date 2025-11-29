return {
  -- Dépendances nécessaires pour Pieces
  { "nvim-tree/nvim-web-devicons", lazy = true },
  { "MunifTanjim/nui.nvim", lazy = true },
  { "hrsh7th/nvim-cmp", lazy = true },

  -- Plugin principal Pieces
  {
    "pieces-app/plugin_neovim",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
      "hrsh7th/nvim-cmp",
    },
    build = function()
      -- Chemin vers ton venv Python (adapte si besoin)
      vim.g.python3_host_prog = "/home/kd/.config/nvim/nvim-python-venv/bin/python"
      -- Installe les dépendances Python dans le venv
      local pip = vim.g.python3_host_prog:gsub("bin/python$", "bin/pip")
      vim.fn.system(pip .. " install --upgrade pynvim pieces_os_client pyyaml")
      -- Met à jour les plugins distants
      vim.cmd("UpdateRemotePlugins")
    end,
    config = function()
      require("pieces").setup()
    end,
    event = "VeryLazy", -- ou adapte selon ton workflow
  },
}
