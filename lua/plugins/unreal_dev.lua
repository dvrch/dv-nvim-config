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

  -- Intégration Unreal
  {
    "goopey7/unreal-support.nvim",
    config = function()
      require("unreal-support").setup({
        -- Répertoire racine de ton UE (facultatif si autodétecté)
        unreal_engine_path = "/home/kd/Bureau/Linux_Unreal_Engine_5.6.0",
        project_path = "/home/kd/Documents/Unreal Projects/city_building_osm_project_files/OSM_Unreal_project/Unreal_project/"
      })
    end,
  },
}