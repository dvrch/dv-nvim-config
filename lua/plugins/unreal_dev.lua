return {
  -- LSP et clangd pour C++
  {
    "neovim/nvim-lspconfig",
    config = function()
      require("lspconfig").clangd.setup({
        cmd = { "clangd", "--header-insertion=never", "--cross-file-rename" },
      })
    end,
  },

  -- Intégration Unreal
  {
    "goopey7/unreal-support.nvim",
    event = { "User LoadHeavy" },
    config = function()

      require("unreal-support").setup({
        -- Répertoire racine de ton UE 5.6
        unreal_engine_path = "/home/kd/Bureau/Linux_Unreal_Engine_5.6.0",
        project_path = "/home/kd/Documents/Unreal Projects/city_building_osm_project_files/OSM_Unreal_project/Unreal_project_5.6/OSM_Project_Files.uproject",
      })

      -- Commande pour lancer le projet Unreal directement depuis Neovim
      vim.api.nvim_create_user_command("UnrealRun", function()
        local editor = "/home/kd/Bureau/Linux_Unreal_Engine_5.6.0/Engine/Binaries/Linux/UnrealEditor"
        local project = "/home/kd/Documents/Unreal Projects/city_building_osm_project_files/OSM_Unreal_project/Unreal_project_5.6/OSM_Project_Files.uproject"
        vim.fn.jobstart({ editor, project }, { detach = true })
        print("🚀 Lancement d'Unreal Engine 5.6...")
      end, {})
    end,
    keys = {
      { "<leader>uR", "<cmd>UnrealRun<cr>", desc = "Run Unreal Project" },
    },
  },
}