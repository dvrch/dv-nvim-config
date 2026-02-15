return {
  -- Molten: Configuration optimisée pour affichage direct
  {
    "benlubas/molten-nvim",
    version = "^1.0.0",
    build = ":UpdateRemotePlugins",
    init = function()
      -- Configuration de l'affichage inline
      vim.g.molten_auto_open_output = true -- Affiche automatiquement le résultat
      vim.g.molten_virt_text_output = true -- Texte virtuel pour les petits résultats
      vim.g.molten_virt_lines_off_by_1 = false -- Affiche SUR la ligne, pas après
      vim.g.molten_output_win_max_height = 20
      vim.g.molten_wrap_output = true
      vim.g.molten_auto_image_popup = true -- Pour les graphiques
      
      -- Configuration du kernel et des images
      vim.g.molten_image_provider = "image.nvim"
      vim.g.molten_default_kernel = "python3"
      vim.g.molten_output_show_more = true
      vim.g.molten_enter_output_behavior = "open_and_enter"
      
      -- Auto-init au chargement d'un notebook
      vim.api.nvim_create_autocmd("BufEnter", {
        pattern = "*.ipynb",
        callback = function()
          vim.defer_fn(function()
            if vim.fn.exists(":MoltenInfo") == 2 then
              pcall(vim.cmd, "silent! MoltenInit python3")
            end
          end, 800)
        end,
      })
    end,
    keys = {
      { "<leader>mk", ":MoltenInit python3<cr>", desc = "Init Kernel" },
      { "<leader>jc", ":MoltenEvaluateOperator<cr>", desc = "Execute Cell" },
      { "<leader>jx", ":MoltenEvaluateLine<cr>", desc = "Execute Line" },
      { "<leader>jv", ":<C-u>MoltenEvaluateVisual<cr>", mode = "v", desc = "Execute Visual" },
      { "<leader>jd", ":MoltenDelete<cr>", desc = "Delete ALL Outputs" },
      { "<leader>jo", ":noautocmd MoltenEnterOutput<cr>", desc = "Enter Output Window" },
      { "<leader>jh", ":MoltenHideOutput<cr>", desc = "Hide Output" },
      { "<leader>jr", ":MoltenReevaluateAll<cr>", desc = "Re-run All Cells" },
    },
  },

  -- Jupytext: Réactivé MAIS sans écriture sur disque
  {
    "GCBallesteros/jupytext.nvim",
    lazy = false,
    opts = {
      custom_outputs = false, -- Pas d'output custom
      style = "percent", -- Format standard # %%
      output_extension = "py",
      force_ft = "python",
    },
    config = function(_, opts)
      require("jupytext").setup(opts)
      
      -- Hook pour empêcher l'écriture automatique des fichiers convertis
      vim.api.nvim_create_autocmd("BufWritePost", {
        pattern = "*.ipynb",
        callback = function()
          -- Supprime les fichiers .py/.md créés automatiquement
          local base = vim.fn.expand("%:r")
          local dir = vim.fn.expand("%:p:h")
          vim.fn.delete(dir .. "/" .. base .. ".py")
          vim.fn.delete(dir .. "/" .. base .. ".md")
        end,
      })
    end,
  },

  -- Quarto: Pour la détection des cellules
  {
    "quarto-dev/quarto-nvim",
    ft = { "quarto", "markdown", "python" },
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

  -- Otter: LSP et coloration dans les blocs
  {
    "jmbuhr/otter.nvim",
    ft = { "quarto", "markdown", "python" },
    opts = {
      buffers = { set_filetype = true },
      handle_leading_whitespace = true,
    },
  },

  -- Image.nvim
  {
    "3rd/image.nvim",
    opts = {
      backend = "kitty",
      integrations = {
        markdown = {
          enabled = true,
          filetypes = { "markdown", "quarto", "python" },
        },
      },
    },
  },
}
