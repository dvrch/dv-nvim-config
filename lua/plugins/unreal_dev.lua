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
    cond = function()
      -- Ne charge ce plugin QUE si on est dans un projet Unreal
      return vim.fn.glob("*.uproject") ~= ""
    end,
    config = function()

      local engine_dir = vim.env.UNREAL_ENGINE_PATH or vim.fn.expand("~/aps/UE_5.7.3")

      require("unreal-support").setup({
        engine_path = engine_dir,
        -- project_path non spécifié = Auto-détection du `.uproject` dans ton workspace actif !
      })

      -- Commande DYNAMIQUE pour lancer le projet Unreal directement depuis Neovim
      vim.api.nvim_create_user_command("UnrealRun", function()
        local us = require("unreal-support")
        local editor = us.engine_path .. "/Engine/Binaries/Linux/UnrealEditor"
        local project = us.project_path .. "/" .. us.project_name .. ".uproject"
        
        if vim.fn.filereadable(editor) == 0 then
            print("❌ Exécutable Unreal introuvable : " .. editor)
            return
        end
        if vim.fn.filereadable(project) == 0 then
            print("❌ Fichier Projet introuvable : " .. project)
            return
        end
        
        vim.fn.jobstart({ editor, project }, { detach = true })
        print("🚀 Lancement d'Unreal Engine (" .. us.project_name .. ")...")
      end, {})
    end,
    keys = {
      { "<leader>uR", "<cmd>UnrealRun<cr>", desc = "Run Unreal Project" },
    },
  },
}