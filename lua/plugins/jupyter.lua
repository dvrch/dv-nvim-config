return {
  -- Molten: Configuration avec prévention de kernels multiples
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
      
      -- Commande: Nettoyer tous les kernels zombies
      vim.api.nvim_create_user_command("MoltenCleanKernels", function()
        vim.cmd("MoltenDeinit")
        vim.notify("🧹 Kernels nettoyés", vim.log.levels.INFO)
      end, {})
      
      -- Commande: Supprimer TOUS les outputs
      vim.api.nvim_create_user_command("MoltenDeleteAllOutputs", function()
        vim.cmd("silent! %MoltenDelete")
        vim.notify("🗑️ Tous les outputs supprimés", vim.log.levels.INFO)
      end, {})
      
      -- Commande: Run All Clean (SANS affichage MoltenInfo)
      vim.api.nvim_create_user_command("MoltenRunAllClean", function()
        -- Pas d'affichage de MoltenInfo pour éviter la boucle
        
        -- 1. Vérifier que Molten est initialisé (sans afficher)
        local initialized = false
        local ok, result = pcall(vim.fn.execute, "MoltenInfo")
        
        if ok and result then
          initialized = result:match("Initialized: true") ~= nil
        end
        
        if not initialized then
          vim.notify("⚠️ Initialisation du kernel...", vim.log.levels.WARN)
          vim.cmd("silent! MoltenInit python3")
          vim.defer_fn(function()
            vim.cmd("MoltenRunAllClean")
          end, 2000)
          return
        end
        
        -- 2. Supprimer outputs
        vim.cmd("silent! %MoltenDelete")
        vim.notify("🧹 Nettoyage + Exécution...", vim.log.levels.INFO)
        
        -- 3. Exécuter cellules
        vim.defer_fn(function()
          local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
          local cell_starts = {}
          
          for i, line in ipairs(lines) do
            if line:match("^# %%") then
              table.insert(cell_starts, i)
            end
          end
          
          if #cell_starts == 0 then
            vim.notify("❌ Aucune cellule (# %%)", vim.log.levels.WARN)
            return
          end
          
          vim.notify("🚀 " .. #cell_starts .. " cellules...", vim.log.levels.INFO)
          
          local current_cell = 1
          local function execute_next_cell()
            if current_cell > #cell_starts then
              vim.notify("✅ Terminé!", vim.log.levels.INFO)
              return
            end
            
            vim.api.nvim_win_set_cursor(0, {cell_starts[current_cell], 0})
            vim.cmd("silent! MoltenReevaluateCell") -- Silent pour pas de popup
            
            current_cell = current_cell + 1
            vim.defer_fn(execute_next_cell, 1000)
          end
          
          execute_next_cell()
        end, 500)
      end, {})
      
      -- Auto-initialisation STRICTE (une seule fois par session Neovim)
      local global_kernel_initialized = false
      
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "python",
        callback = function()
          -- Ne s'exécute qu'une seule fois globalement
          if global_kernel_initialized then
            return
          end
          
          local filename = vim.fn.expand("%:t")
          if not filename:match("%.ipynb") then
            return
          end
          
          global_kernel_initialized = true
          
          vim.defer_fn(function()
            local ok, result = pcall(vim.fn.execute, "MoltenInfo")
            if ok and result and result:match("Initialized: true") then
              return
            end
            
            vim.cmd("silent! MoltenInit python3")
            vim.notify("🐍 Kernel initialisé", vim.log.levels.INFO)
          end, 1500)
        end,
      })
    end,
    keys = {
      { "<leader>mk", ":MoltenInit python3<cr>", desc = "Init/Restart Kernel" },
      { "<leader>mK", ":MoltenCleanKernels<cr>", desc = "Clean All Kernels" },
      
      { "<leader>jc", ":MoltenReevaluateCell<cr>", desc = "Execute CELL (P1)" },
      { "<leader>jv", ":<C-u>MoltenEvaluateVisual<cr>", mode = "v", desc = "Execute SELECTION (P2)" },
      { "<leader>jx", ":MoltenEvaluateLine<cr>", desc = "Execute Line (P3)" },
      
      { "<leader>ja", ":MoltenRunAllClean<cr>", desc = "Run All Clean" },
      
      { "<leader>jd", ":MoltenDelete<cr>", desc = "Delete Current Output" },
      { "<leader>jD", ":MoltenDeleteAllOutputs<cr>", desc = "Delete ALL Outputs" },
      { "<leader>jo", ":noautocmd MoltenEnterOutput<cr>", desc = "Open Output" },
      { "<leader>jh", ":MoltenHideOutput<cr>", desc = "Hide Output" },
      
      { "<leader>ji", ":MoltenInterrupt<cr>", desc = "Interrupt" },
    },
  },

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

  {
    "quarto-dev/quarto-nvim",
    ft = { "quarto", "markdown", "python" },
    opts = {
      lspFeatures = { languages = { "python", "bash" }, chunks = "all" },
      codeRunner = { enabled = true, default_method = "molten" },
    },
  },

  {
    "jmbuhr/otter.nvim",
    ft = { "quarto", "markdown", "python" },
    opts = { buffers = { set_filetype = true }, handle_leading_whitespace = true },
  },

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
