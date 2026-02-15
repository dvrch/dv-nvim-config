return {
  -- Molten: Configuration des raccourcis harmonisée
  {
    "benlubas/molten-nvim",
    enabled = true,
    build = ":UpdateRemotePlugins",
    init = function()
      vim.g.molten_auto_open_output = true
      vim.g.molten_image_provider = "image.nvim"
      vim.g.molten_output_win_max_height = 12
      vim.g.molten_virt_text_output = true 
      vim.g.molten_virt_lines_off_by_1 = true
      vim.g.molten_default_kernel = "python3"
      
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "python", "quarto", "markdown" },
        callback = function()
          vim.fn.matchadd("Conceal", "^# %%", 10, -1, { conceal = "━" })
          vim.opt_local.conceallevel = 2
        end,
      })
    end,
    keys = {
      -- INITIALISATION
      { "<leader>mk", ":MoltenInit python3<cr>", desc = "Init Kernel (Python)" },
      
      -- EXÉCUTION
      { "<leader>jx", ":MoltenEvaluateLine<cr>", desc = "Execute Line" },
      { "<leader>jc", ":MoltenReevaluateCell<cr>", desc = "Execute Cell" },
      { "<leader>jv", ":<C-u>MoltenEvaluateVisual<cr>", mode = "v", desc = "Execute Visual" },
      
      -- GESTION OUPUT
      { "<leader>jo", ":MoltenShowOutput<cr>", desc = "Show Output Window" },
      { "<leader>jh", ":MoltenHideOutput<cr>", desc = "Hide Output Window" },
      { "<leader>jd", ":MoltenDelete<cr>", desc = "Delete Current Output" },
      
      -- AIDE
      { "<leader>jm", ":vsplit ~/.config/nvim/JUPYTER_HELP.md<cr>", desc = "Jupyter Help Guide" },
    },
  },

  -- Jupytext, Quarto, Otter, Image.nvim (Config inchangée mais maintenue pour la cohérence)
  {
    "GCBallesteros/jupytext.nvim",
    lazy = false,
    opts = {
      custom_outputs = true,
      style = "hydrogen", 
      output_extension = "py",
      force_ft = "python",
    },
  },
  {
    "quarto-dev/quarto-nvim",
    opts = {
      lspFeatures = { languages = { "python", "bash" }, chunks = "all" },
      codeRunner = { enabled = true, default_method = "molten" },
    },
  },
  {
    "jmbuhr/otter.nvim",
    opts = { buffers = { set_filetype = true, write_to_disk = false } },
  },
  {
    "3rd/image.nvim",
    event = "VeryLazy",
    opts = {
      backend = "kitty", 
      integrations = {
        markdown = { enabled = true, filetypes = { "markdown", "quarto", "python" } },
      },
    },
  },
}
