return {
  -- Molten: Configuration avancée pour l'affichage des résultats et délimitations
  {
    "benlubas/molten-nvim",
    enabled = true,
    build = ":UpdateRemotePlugins",
    init = function()
      -- Paramètres pour l'affichage automatique des résultats
      vim.g.molten_auto_open_output = true -- Affiche le résultat automatiquement ! ✅
      vim.g.molten_image_provider = "image.nvim"
      vim.g.molten_output_win_max_height = 12
      vim.g.molten_virt_text_output = true 
      vim.g.molten_virt_lines_off_by_1 = true
      
      -- Noyau par défaut
      vim.g.molten_default_kernel = "python3"
      
      -- Délimitations visuelles (VirtColumn) pour les cellules
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "python", "quarto", "markdown" },
        callback = function()
          -- On simule des lignes horizontales via le colorcolumn ou des signes
          vim.fn.matchadd("Conceal", "^# %%", 10, -1, { conceal = "━" })
          vim.opt_local.conceallevel = 2
        end,
      })
    end,
    keys = {
      { "<leader>mk", ":MoltenInit python3<cr>", desc = "Init Python3 Kernel" },
      { "<leader>rl", ":MoltenEvaluateLine<cr>", desc = "Evaluate Line" },
      { "<leader>rc", ":MoltenReevaluateCell<cr>", desc = "Re-evaluate Cell" },
      { "<leader>rd", ":MoltenDelete<cr>", desc = "Delete Cell Output" },
      { "<leader>os", ":MoltenShowOutput<cr>", desc = "Show Output" },
    },
  },

  -- Jupytext: On force le format Hydrogen (# %%) pour une détection parfaite
  {
    "GCBallesteros/jupytext.nvim",
    lazy = false,
    opts = {
      custom_outputs = true,
      style = "hydrogen", 
      output_extension = "py",
      force_ft = "python", -- On utilise python pour avoir la coloration syntaxique du code !
    },
  },

  -- Quarto: Crucial pour la coloration mixte (Markdown + Python)
  {
    "quarto-dev/quarto-nvim",
    dependencies = {
      "jmbuhr/otter.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    opts = {
      lspFeatures = {
        languages = { "python", "bash" },
        chunks = "all",
      },
      codeRunner = {
        enabled = true,
        default_method = "molten",
      },
    },
  },

  -- Otter: Paint l'LSP et la coloration syntaxique à l'intérieur des blocs
  {
    "jmbuhr/otter.nvim",
    opts = {
      buffers = {
        set_filetype = true,
        write_to_disk = false,
      },
    },
  },
}
