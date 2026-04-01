return {
  -- 🦦 Otter.nvim : Fournit l'auto-complétion (LSP) d'un langage 
  -- à l'intérieur d'un autre (ex: Python dans Markdown/Jupyter).
  {
    "jmbuhr/otter.nvim",
    dependencies = {
      "neovim/nvim-lspconfig",
    },
    opts = {
      lsp = {
        -- Utilise pyright (qui a déjà les chemins Houdini) pour les blocs de code
        hover = { border = "rounded" },
      },
    },
    config = function(_, opts)
      require("otter").setup(opts)
      
      -- Activation automatique d'Otter dans les fichiers Markdown et Jupyter
      vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
        pattern = { "*.md", "*.ipynb", "*.jmd" },
        callback = function()
          require("otter").activate({ "python", "lua", "bash" }, true, true, nil)
        end,
      })
    end,
  },
}
