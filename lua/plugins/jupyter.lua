return {
  -- Molten: Le moteur d'exécution interactif (remplaçant de Magma)
  {
    "benlubas/molten-nvim",
    enabled = true,
    build = ":UpdateRemotePlugins",
    init = function()
      -- Paramètres pour une meilleure expérience visuelle
      vim.g.molten_auto_open_output = false
      vim.g.molten_image_provider = "image.nvim"
      vim.g.molten_output_win_max_height = 12
      vim.g.molten_virt_text_output = true
      vim.g.molten_virt_lines_off_by_1 = true
      
      -- Noyau par défaut pour éviter de demander à chaque fois
      vim.g.molten_default_kernel = "python3"
      
      -- Sauvegarde auto des résultats dans le fichier (si supporté)
      vim.g.molten_save_init_args = true
      vim.g.molten_auto_init_behavior = "init_import"
    end,
    keys = {
      { "<leader>mj", ":MoltenInit<cr>", desc = "Initialize Molten" },
      { "<leader>mk", ":MoltenInit python3<cr>", desc = "Init Python3 Kernel (Default)" },
      { "<leader>me", ":MoltenEvaluateOperator<cr>", desc = "Evaluate Operator" },
      { "<leader>rl", ":MoltenEvaluateLine<cr>", desc = "Evaluate Line" },
      { "<leader>rc", ":MoltenReevaluateCell<cr>", desc = "Re-evaluate Cell" },
      { "<leader>rd", ":MoltenDelete<cr>", desc = "Delete Cell Output" },
      { "<leader>rv", ":<C-u>MoltenEvaluateVisual<cr>", mode = "v", desc = "Evaluate Visual" },
      { "<leader>oh", ":MoltenHideOutput<cr>", desc = "Hide Output" },
      { "<leader>os", ":MoltenShowOutput<cr>", desc = "Show Output" },
      { "<leader>mh", ":vsplit ~/.config/nvim/JUPYTER_HELP.md<cr>", desc = "Jupyter Help" },
    },
  },

  -- Jupytext: Correction pour la détection des cellules
  {
    "GCBallesteros/jupytext.nvim",
    lazy = false,
    opts = {
      custom_outputs = true,
      style = "hydrogen", -- Le style hydrogen/percent est le meilleur pour la détection de cellules
      output_extension = "py",
      force_ft = "python",
    },
  },

  -- Quarto: Pour une expérience Notebook complète (Markdown + Code)
  {
    "quarto-dev/quarto-nvim",
    dependencies = {
      "jmbuhr/otter.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    opts = {
      lspFeatures = {
        languages = { "python", "r", "julia", "bash" },
        chunks = "all",
        diagnostics = {
          enabled = true,
          triggers = { "BufWritePost" },
        },
        completion = {
          enabled = true,
        },
      },
      codeRunner = {
        enabled = true,
        default_method = "molten",
      },
    },
  },

  -- Otter: Fournit l'LSP (completion, go-to-def) dans les blocs de code Markdown
  {
    "jmbuhr/otter.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
    },
    opts = {
      buffers = {
        set_filetype = true,
      },
    },
  },

  -- Gestion des images (pour voir les plots de matplotlib, etc.)
  {
    "3rd/image.nvim",
    event = "VeryLazy",
    opts = {
      backend = "kitty", 
      integrations = {
        markdown = {
          enabled = true,
          clear_in_insert_mode = false,
          download_remote_images = true,
          only_render_image_at_cursor = false,
          filetypes = { "markdown", "quarto", "python" },
        },
      },
      max_width = 100,
      max_height = 12,
      window_overlap_clear_enabled = true,
    },
  },
}
