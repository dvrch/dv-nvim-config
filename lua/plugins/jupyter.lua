return {
  -- Molten: Configuration avec initialisation synchrone robuste
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
      vim.g.molten_use_border_highlights = true
      
      -- Commande: Supprimer TOUS les outputs
      vim.api.nvim_create_user_command("MoltenDeleteAllOutputs", function()
        vim.cmd("silent! %MoltenDelete")
        vim.notify("🗑️ Tous les outputs supprimés", vim.log.levels.INFO)
      end, {})
      
      -- Commande: Run All Clean avec vérification du kernel
      vim.api.nvim_create_user_command("MoltenRunAllClean", function()
        -- 1. Vérifier que Molten est initialisé
        local initialized = false
        local ok, result = pcall(vim.fn.execute, "MoltenInfo")
        
        if ok and result then
          initialized = result:match("Initialized: true") ~= nil
        end
        
        if not initialized then
          vim.notify("⚠️ Initialisation du kernel...", vim.log.levels.WARN)
          vim.cmd("MoltenInit python3")
          -- Attendre que le kernel soit prêt
          vim.defer_fn(function()
            vim.cmd("MoltenRunAllClean") -- Rappel récursif après init
          end, 2000)
          return
        end
        
        -- 2. Supprimer tous les outputs
        vim.cmd("silent! %MoltenDelete")
        vim.notify("🧹 Outputs nettoyés, exécution...", vim.log.levels.INFO)
        
        -- 3. Exécuter toutes les cellules
        vim.defer_fn(function()
          local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
          local cell_starts = {}
          
          for i, line in ipairs(lines) do
            if line:match("^# %%") then
              table.insert(cell_starts, i)
            end
          end
          
          if #cell_starts == 0 then
            vim.notify("❌ Aucune cellule trouvée (# %%)", vim.log.levels.WARN)
            return
          end
          
          vim.notify("🚀 Exécution de " .. #cell_starts .. " cellules...", vim.log.levels.INFO)
          
          local current_cell = 1
          local function execute_next_cell()
            if current_cell > #cell_starts then
              vim.notify("✅ Toutes les cellules exécutées!", vim.log.levels.INFO)
              return
            end
            
            vim.api.nvim_win_set_cursor(0, {cell_starts[current_cell], 0})
            vim.cmd("MoltenReevaluateCell")
            
            current_cell = current_cell + 1
            vim.defer_fn(execute_next_cell, 1000) -- 1 seconde entre chaque
          end
          
          execute_next_cell()
        end, 500)
      end, {})
      
      -- Auto-initialisation ROBUSTE et UNIQUE
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "python", -- Déclenché quand Jupytext convertit en Python
        once = false, -- On permet plusieurs déclenchements
        callback = function()
          -- Vérifier si c'est un notebook
          local filename = vim.fn.expand("%:t")
          if not filename:match("%.ipynb") then
            return
          end
          
          -- Vérifier si déjà initialisé
          local ok, result = pcall(vim.fn.execute, "MoltenInfo")
          if ok and result and result:match("Initialized: true") then
            return -- Déjà initialisé
          end
          
          -- Initialiser après un délai
          vim.defer_fn(function()
            vim.cmd("silent! MoltenInit python3")
            vim.notify("🐍 Kernel Python 3 initialisé", vim.log.levels.INFO)
          end, 1500)
        end,
      })
    end,
    keys = {
      -- INITIALISATION
      { "<leader>mk", ":MoltenInit python3<cr>", desc = "Init/Restart Kernel" },
      
      -- EXÉCUTION (Priorités claires)
      { "<leader>jc", ":MoltenReevaluateCell<cr>", desc = "Execute CELL (P1)" },
      { "<leader>jv", ":<C-u>MoltenEvaluateVisual<cr>", mode = "v", desc = "Execute SELECTION (P2)" },
      { "<leader>jx", ":MoltenEvaluateLine<cr>", desc = "Execute Line (P3)" },
      
      -- GLOBAL
      { "<leader>ja", ":MoltenRunAllClean<cr>", desc = "Run All Clean" },
      
      -- OUTPUTS
      { "<leader>jd", ":MoltenDelete<cr>", desc = "Delete Current Output" },
      { "<leader>jD", ":MoltenDeleteAllOutputs<cr>", desc = "Delete ALL Outputs" },
      { "<leader>jo", ":noautocmd MoltenEnterOutput<cr>", desc = "Open Output" },
      { "<leader>jh", ":MoltenHideOutput<cr>", desc = "Hide Output" },
      
      -- CONTRÔLE
      { "<leader>ji", ":MoltenInterrupt<cr>", desc = "Interrupt" },
    },
  },

  -- Jupytext avec nettoyage auto
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
      
      -- Nettoyage auto des fichiers temporaires
      vim.api.nvim_create_autocmd("BufWritePost", {
        pattern = "*.ipynb",
        callback = function()
          vim.defer_fn(function()
            local base = vim.fn.expand("%:r")
            local dir = vim.fn.expand("%:p:h")
            os.remove(dir .. "/" .. base .. ".py")
            os.remove(dir .. "/" .. base .. ".md")
          end, 100)
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
