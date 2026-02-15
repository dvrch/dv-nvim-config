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
    end,
    keys = {
      { "<leader>mj", ":MoltenInit<cr>", desc = "Initialize Molten" },
      { "<leader>me", ":MoltenEvaluateOperator<cr>", desc = "Evaluate Operator" },
      { "<leader>rl", ":MoltenEvaluateLine<cr>", desc = "Evaluate Line" },
      { "<leader>rc", ":MoltenReevaluateCell<cr>", desc = "Re-evaluate Cell" },
      { "<leader>rd", ":MoltenDeleteRaw<cr>", desc = "Delete Cell Output" },
      { "<leader>rv", ":<C-u>MoltenEvaluateVisual<cr>", mode = "v", desc = "Evaluate Visual" },
      { "<leader>oh", ":MoltenHideOutput<cr>", desc = "Hide Output" },
      { "<leader>os", ":MoltenShowOutput<cr>", desc = "Show Output" },
      { "<leader>mh", ":vsplit ~/.config/nvim/JUPYTER_HELP.md<cr>", desc = "Jupyter Help" },
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

  -- Jupytext: Permet d'éditer des .ipynb comme du texte (Markdown/Python)
  {
    "GCBallesteros/jupytext.nvim",
    lazy = false,
    opts = {
      custom_outputs = true,
      style = "markdown",
      output_extension = "md",
      force_ft = "markdown",
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
      backend = "kitty", -- Tentative avec kitty, s'adapte à beaucoup de terminaux modernes
      integrations = {
        markdown = {
          enabled = true,
          clear_in_insert_mode = false,
          download_remote_images = true,
          only_render_image_at_cursor = false,
          filetypes = { "markdown", "quarto" },
        },
      },
      max_width = 100,
      max_height = 12,
      window_overlap_clear_enabled = true,
    },
  },

  -- Harmonisation des couleurs pour Molten
  {
    "AstroNvim/astrotheme",
    optional = true,
    opts = {
      highlights = {
        molten = {
          MoltenOutputWin = { bg = "NONE" },
          MoltenOutputWinBorder = { fg = "Primary" },
        },
      },
    },
  },
}
