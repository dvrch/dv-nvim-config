return {
  -- Molten: Moteur haute performance avec affichage sous les lignes
  {
    "benlubas/molten-nvim",
    version = "^1.0.0", -- Utilisez la version stable
    build = ":UpdateRemotePlugins",
    init = function()
      -- AFFICHAGE : On veut que ça apparaisse SOUS la ligne
      vim.g.molten_auto_open_output = false -- On désactive le float auto pour privilégier le texte virtuel
      vim.g.molten_virt_text_output = true  -- Affiche le résultat en texte virtuel à côté de la ligne
      vim.g.molten_virt_lines_off_by_1 = true -- Met le résultat sur la ligne d'en dessous ✅
      
      -- PROVIDER D'IMAGES
      vim.g.molten_image_provider = "image.nvim"
      
      -- COMPORTEMENT DES FENÊTRES
      vim.g.molten_output_win_max_height = 15
      vim.g.molten_output_virt_line_max_height = 15
      
      -- NOYAU PAR DÉFAUT
      vim.g.molten_default_kernel = "python3"

      -- DÉCORATIONS VISUELLES (LIGNES HORIZONTALES)
      -- On utilise des "Sign Column" ou des "Virtual Text" pour délimiter les cellules sans changer le fichier
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "python", "quarto", "markdown" },
        callback = function()
          -- Tracer une ligne virtuelle sur les marqueurs de cellules
          vim.fn.matchadd("Conceal", "^# %%", 10, -1, { conceal = "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" })
          vim.fn.matchadd("Conceal", "^```python", 10, -1, { conceal = "󱗼 Python Cell ━━━━━━━━━━━━━━━━━━━━━━━━━" })
          vim.opt_local.conceallevel = 2
        end,
      })
    end,
    keys = {
      { "<leader>mk", ":MoltenInit python3<cr>", desc = "Init Kernel" },
      { "<leader>jc", ":MoltenReevaluateCell<cr>", desc = "Execute Cell" },
      { "<leader>jx", ":MoltenEvaluateLine<cr>", desc = "Execute Line" },
      { "<leader>jd", ":MoltenDelete<cr>", desc = "Delete Output (Cell/Line)" },
      { "<leader>jo", ":MoltenShowOutput<cr>", desc = "Show Detailed Output (Float)" },
      { "<leader>jh", ":MoltenHideOutput<cr>", desc = "Hide Output" },
    },
  },

  -- Jupytext : Switch en mode 'markdown' pour avoir la double coloration (MD + Code)
  {
    "GCBallesteros/jupytext.nvim",
    lazy = false,
    opts = {
      custom_outputs = true,
      style = "markdown", -- Utilise les blocs ```python au lieu de # %%
      output_extension = "md",
      force_ft = "markdown",
    },
  },

  -- Quarto : C'est lui qui gère la coloration mixte et le lien avec Molten
  {
    "quarto-dev/quarto-nvim",
    dependencies = {
      "jmbuhr/otter.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    opts = {
      lspFeatures = {
        languages = { "python", "bash", "lua" },
        chunks = "all",
      },
      codeRunner = {
        enabled = true,
        default_method = "molten",
      },
    },
  },

  -- Otter : L'intelligence (LSP + Coloration) dans les blocs de code
  {
    "jmbuhr/otter.nvim",
    opts = {
      buffers = {
        set_filetype = true,
      },
      handle_leading_whitespace = true,
    },
  },

  -- Image.nvim : Pour les graphiques
  {
    "3rd/image.nvim",
    opts = {
      backend = "kitty",
      integrations = {
        markdown = {
          enabled = true,
          only_render_image_at_cursor = false,
          filetypes = { "markdown", "quarto" },
        },
      },
    },
  },
}
