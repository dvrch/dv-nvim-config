return {
  -- LSP et clangd pour C++
  {
    "neovim/nvim-lspconfig",
    config = function()
      require("lspconfig").clangd.setup {
        cmd = { "clangd", "--header-insertion=never", "--cross-file-rename" },
      }
    end,
  },

  -- Treesitter pour C++
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      ensure_installed = { "cpp", "lua", "cmake", "markdown", "markdown_inline", "yaml", "latex" },
      highlight = { enable = true },
      indent = { enable = true },
    },
    config = function(_, opts)
      require("nvim-treesitter.config").setup(opts)
    end,
  },

  -- Intégration Unreal
  {
    "goopey7/unreal-support.nvim",
    config = function()
      require("unreal-support").setup({
        -- Répertoire racine de ton UE (facultatif si autodétecté)
        unreal_engine_path = "/home/kd/Bureau/Linux_Unreal_Engine_5.6.0",
        project_root = "/home/kd/Documents/Unreal Projects/city_building_osm_project_files/OSM_Unreal_project/Unreal_project/"
      })
    end,
  },
}