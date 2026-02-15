return {
  -- Molten: Moteur d'exécution avec affichage inline
  {
    "benlubas/molten-nvim",
    version = "^1.0.0",
    build = ":UpdateRemotePlugins",
    init = function()
      -- Affichage inline (sous les lignes)
      vim.g.molten_auto_open_output = false
      vim.g.molten_virt_text_output = true
      vim.g.molten_virt_lines_off_by_1 = true
      vim.g.molten_output_win_max_height = 15
      vim.g.molten_image_provider = "image.nvim"
      vim.g.molten_default_kernel = "python3"
      
      -- Auto-initialisation pour les fichiers .ipynb
      vim.api.nvim_create_autocmd("BufEnter", {
        pattern = "*.ipynb",
        callback = function()
          -- Attend un peu que le buffer soit prêt
          vim.defer_fn(function()
            -- Vérifie si un kernel est déjà initialisé
            if vim.fn.exists(":MoltenInfo") == 2 then
              local status = vim.fn.execute("MoltenInfo")
              if not status:match("python3") then
                vim.cmd("MoltenInit python3")
              end
            end
          end, 500)
        end,
      })
    end,
    keys = {
      { "<leader>mk", ":MoltenInit python3<cr>", desc = "Init Kernel" },
      { "<leader>jc", ":MoltenReevaluateCell<cr>", desc = "Execute Cell" },
      { "<leader>jx", ":MoltenEvaluateLine<cr>", desc = "Execute Line" },
      { "<leader>jd", ":MoltenDelete<cr>", desc = "Delete Output" },
      { "<leader>jo", ":MoltenShowOutput<cr>", desc = "Show Output (Float)" },
    },
  },

  -- Jupytext : DÉSACTIVÉ complètement pour éviter la création de fichiers .md/.py
  {
    "GCBallesteros/jupytext.nvim",
    enabled = false, -- ✅ DÉSACTIVÉ
  },

  -- Quarto : Pour la détection des cellules dans les .ipynb sans conversion
  {
    "quarto-dev/quarto-nvim",
    ft = { "quarto", "markdown" },
    dependencies = {
      "jmbuhr/otter.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    opts = {
      lspFeatures = {
        languages = { "python", "bash" },
        chunks = "curly",
      },
      codeRunner = {
        enabled = true,
        default_method = "molten",
      },
    },
  },

  -- Otter : LSP dans les blocs de code
  {
    "jmbuhr/otter.nvim",
    ft = { "quarto", "markdown" },
    opts = {
      buffers = {
        set_filetype = true,
      },
    },
  },

  -- Image.nvim pour les graphiques
  {
    "3rd/image.nvim",
    opts = {
      backend = "kitty",
      integrations = {
        markdown = {
          enabled = true,
          filetypes = { "markdown", "quarto" },
        },
      },
    },
  },
}
