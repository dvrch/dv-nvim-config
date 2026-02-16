return {
  -- Molten: Configuration MINIMALISTE sans auto-init
  {
    "benlubas/molten-nvim",
    version = "^1.0.0",
    build = ":UpdateRemotePlugins",
    init = function()
      -- Configuration affichage
      vim.g.molten_auto_open_output = true
      vim.g.molten_virt_text_output = true
      vim.g.molten_virt_lines_off_by_1 = false
      vim.g.molten_output_win_max_height = 20
      vim.g.molten_wrap_output = true
      vim.g.molten_auto_image_popup = true
      vim.g.molten_image_provider = "image.nvim"
      vim.g.molten_output_show_more = true
      vim.g.molten_enter_output_behavior = "open_and_enter"
      
      -- Commande: Nettoyer TOUS les kernels (tue les process Python)
      vim.api.nvim_create_user_command("MoltenKillAll", function()
        vim.cmd("MoltenDeinit")
        vim.fn.system("pkill -f ipykernel")
        vim.notify("💀 Tous les kernels tués", vim.log.levels.WARN)
      end, {})
      
      -- Commande: Run All SIMPLE (sans vérifications compliquées)
      vim.api.nvim_create_user_command("MoltenRunAll", function()
        -- Sauvegarder le réglage auto_open
        local old_auto_open = vim.g.molten_auto_open_output
        vim.g.molten_auto_open_output = false
        
        -- Nettoyer d'abord
        vim.cmd("silent! %MoltenDelete")
        
        -- Trouver les cellules
        local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
        local cell_starts = {}
        
        for i, line in ipairs(lines) do
          if line:match("^# %%") then
            table.insert(cell_starts, i)
          end
        end
        
        if #cell_starts == 0 then
          vim.notify("❌ Aucune cellule détectée (format # %%)", vim.log.levels.ERROR)
          vim.g.molten_auto_open_output = old_auto_open
          return
        end
        
        vim.notify("🚀 Exécution de " .. #cell_starts .. " cellules", vim.log.levels.INFO)
        
        -- Exécution séquentielle
        local current = 1
        local function next_cell()
          if current > #cell_starts then
            vim.notify("✅ Terminé!", vim.log.levels.INFO)
            -- Restaurer le réglage original
            vim.g.molten_auto_open_output = old_auto_open
            return
          end
          
          vim.api.nvim_win_set_cursor(0, {cell_starts[current], 0})
          vim.cmd("silent! MoltenReevaluateCell")
          current = current + 1
          vim.defer_fn(next_cell, 1500) -- Délai légèrement augmenté pour stabilité
        end
        
        next_cell()
      end, {})
      
      -- Nettoyage automatique à la fermeture pour éviter les kernels zombies
      vim.api.nvim_create_autocmd("VimLeavePre", {
        callback = function()
          vim.fn.system("pkill -9 -f ipykernel")
        end
      })
    end,
    keys = {
      -- INITIALISATION MANUELLE UNIQUEMENT
      { "<leader>mk", ":MoltenInit python3<cr>", desc = "🐍 Init Kernel (MANUEL)" },
      { "<leader>mK", ":MoltenKillAll<cr>", desc = "💀 Kill ALL Kernels" },
      
      -- EXÉCUTION
      { "<leader>jc", ":MoltenReevaluateCell<cr>", desc = "▶️ Execute CELL" },
      { "<leader>jv", ":<C-u>MoltenEvaluateVisual<cr>", mode = "v", desc = "▶️ Execute SELECTION" },
      { "<leader>jx", ":MoltenEvaluateLine<cr>", desc = "▶️ Execute Line" },
      
      -- RUN ALL (version simple)
      { "<leader>ja", ":MoltenRunAll<cr>", desc = "🚀 Run ALL Cells" },
      
      -- OUTPUTS
      { "<leader>jd", ":MoltenDelete<cr>", desc = "🗑️ Delete Current Output" },
      { "<leader>jD", ":silent! %MoltenDelete<cr>", desc = "🗑️ Delete ALL Outputs" },
      { "<leader>jo", ":noautocmd MoltenEnterOutput<cr>", desc = "📊 Open Output" },
      
      -- INTERRUPTION
      { "<leader>ji", ":MoltenInterrupt<cr>", desc = "⏸️ Interrupt" },
    },
  },

  -- Jupytext: Minimal config
  {
    "GCBallesteros/jupytext.nvim",
    lazy = false,
    opts = {
      custom_outputs = false,
      style = "percent", -- Format # %%
      output_extension = "py",
      force_ft = "python",
    },
  },

  -- Autres plugins (simplifiés)
  {
    "quarto-dev/quarto-nvim",
    enabled = false, -- Désactivé car cause des interférences
  },
  
  {
    "jmbuhr/otter.nvim",
    enabled = false, -- Désactivé temporairement
  },

  {
    "3rd/image.nvim",
    opts = {
      backend = "kitty",
      integrations = {
        markdown = { enabled = true, filetypes = { "python" } },
      },
    },
  },
}
