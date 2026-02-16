return {
  -- Molten: Configuration stricte et commandes personnalisées
  {
    "benlubas/molten-nvim",
    version = "^1.0.0",
    build = ":UpdateRemotePlugins",
    init = function()
      -- Configuration de l'affichage
      vim.g.molten_auto_open_output = true
      vim.g.molten_virt_text_output = true
      vim.g.molten_virt_lines_off_by_1 = false
      vim.g.molten_output_win_max_height = 20
      vim.g.molten_wrap_output = true
      vim.g.molten_auto_image_popup = true
      vim.g.molten_image_provider = "image.nvim"
      vim.g.molten_output_show_more = true
      vim.g.molten_enter_output_behavior = "open_and_enter"
      
      -- IMPORTANT: Utiliser toujours python3 par défaut
      vim.g.molten_use_border_highlights = true
      
      -- Fonction: Supprimer TOUS les outputs de TOUTES les cellules
      vim.api.nvim_create_user_command("MoltenDeleteAllOutputs", function()
        -- On parcourt tous les kernels actifs et on supprime leurs outputs
        vim.cmd("silent! %MoltenDelete")
        vim.notify("🗑️ Tous les outputs supprimés", vim.log.levels.INFO)
      end, {})
      
      -- Fonction: Run All Clean (Supprimer tout + Exécuter toutes les cellules séquentiellement)
      vim.api.nvim_create_user_command("MoltenRunAllClean", function()
        -- 1. Supprimer tous les outputs
        vim.cmd("silent! %MoltenDelete")
        vim.notify("🧹 Nettoyage des outputs...", vim.log.levels.INFO)
        
        -- 2. Attendre un peu puis exécuter toutes les cellules
        vim.defer_fn(function()
          -- Chercher toutes les cellules (marqueurs # %%)
          local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
          local cell_starts = {}
          
          for i, line in ipairs(lines) do
            if line:match("^# %%") then
              table.insert(cell_starts, i)
            end
          end
          
          if #cell_starts == 0 then
            vim.notify("❌ Aucune cellule trouvée (marqueurs # %%)", vim.log.levels.WARN)
            return
          end
          
          vim.notify("🚀 Exécution de " .. #cell_starts .. " cellules...", vim.log.levels.INFO)
          
          -- Fonction récursive pour exécuter les cellules une par une
          local current_cell = 1
          local function execute_next_cell()
            if current_cell > #cell_starts then
              vim.notify("✅ Toutes les cellules exécutées!", vim.log.levels.INFO)
              return
            end
            
            -- Aller à la cellule
            vim.api.nvim_win_set_cursor(0, {cell_starts[current_cell], 0})
            
            -- Exécuter
            vim.cmd("MoltenReevaluateCell")
            
            -- Passer à la suivante après un délai
            current_cell = current_cell + 1
            vim.defer_fn(execute_next_cell, 800) -- 800ms entre chaque cellule
          end
          
          execute_next_cell()
        end, 500)
      end, {})
      
      -- Auto-initialisation UNIQUE au premier BufEnter (pas à chaque fois)
      local molten_initialized = false
      vim.api.nvim_create_autocmd("BufEnter", {
        pattern = "*.ipynb",
        callback = function()
          if not molten_initialized then
            molten_initialized = true
            vim.defer_fn(function()
              -- Vérifier s'il y a déjà un kernel
              local ok, result = pcall(vim.fn.execute, "MoltenInfo")
              if ok and result:match("python3") then
                return -- Kernel déjà actif, ne rien faire
              end
              
              -- Initialiser silencieusement avec python3 par défaut
              vim.cmd("silent! MoltenInit python3")
              vim.notify("🐍 Kernel Python 3 initialisé", vim.log.levels.INFO)
            end, 1000)
          end
        end,
      })
    end,
    keys = {
      -- INITIALISATION (rarement utile car auto-init)
      { "<leader>mk", ":MoltenInit python3<cr>", desc = "Init Kernel (Manual)" },
      
      -- EXÉCUTION (Priorité 1: Cellule, Priorité 2: Sélection, Priorité 3: Ligne)
      { "<leader>jc", ":MoltenReevaluateCell<cr>", desc = "Execute CELL (Priorité 1)" },
      { "<leader>jv", ":<C-u>MoltenEvaluateVisual<cr>", mode = "v", desc = "Execute SELECTION" },
      { "<leader>jx", ":MoltenEvaluateLine<cr>", desc = "Execute Line (Priorité 3)" },
      
      -- EXÉCUTION GLOBALE
      { "<leader>ja", ":MoltenRunAllClean<cr>", desc = "Run ALL Clean (Delete + Execute All)" },
      
      -- GESTION DES OUTPUTS
      { "<leader>jd", ":MoltenDelete<cr>", desc = "Delete Current Cell Output" },
      { "<leader>jD", ":MoltenDeleteAllOutputs<cr>", desc = "Delete ALL Outputs (Toutes cellules)" },
      { "<leader>jo", ":noautocmd MoltenEnterOutput<cr>", desc = "Open Output Window" },
      { "<leader>jh", ":MoltenHideOutput<cr>", desc = "Hide Output" },
      
      -- INTERRUPTION
      { "<leader>ji", ":MoltenInterrupt<cr>", desc = "Interrupt Execution" },
    },
  },

  -- Jupytext: Avec nettoyage auto des fichiers temporaires
  {
    "GCBallesteros/jupytext.nvim",
    lazy = false,
    opts = {
      custom_outputs = false,
      style = "percent",
      output_extension = "py",
      force_ft = "python",
    },
    config = function(_, opts)
      require("jupytext").setup(opts)
      
      vim.api.nvim_create_autocmd("BufWritePost", {
        pattern = "*.ipynb",
        callback = function()
          local base = vim.fn.expand("%:r")
          local dir = vim.fn.expand("%:p:h")
          vim.fn.delete(dir .. "/" .. base .. ".py")
          vim.fn.delete(dir .. "/" .. base .. ".md")
        end,
      })
    end,
  },

  -- Quarto
  {
    "quarto-dev/quarto-nvim",
    ft = { "quarto", "markdown", "python" },
    opts = {
      lspFeatures = { languages = { "python", "bash" }, chunks = "all" },
      codeRunner = { enabled = true, default_method = "molten" },
    },
  },

  -- Otter
  {
    "jmbuhr/otter.nvim",
    ft = { "quarto", "markdown", "python" },
    opts = { buffers = { set_filetype = true }, handle_leading_whitespace = true },
  },

  -- Image.nvim
  {
    "3rd/image.nvim",
    opts = {
      backend = "kitty",
      integrations = {
        markdown = { enabled = true, filetypes = { "markdown", "quarto", "python" } },
      },
    },
  },
}
