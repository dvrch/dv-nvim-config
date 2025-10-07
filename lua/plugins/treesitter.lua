return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
    },
    opts = {
      sync_install = false,
      highlight = { enable = true },
      indent = { enable = true },
      ensure_installed = {
        "bash",
        "markdown",
        "markdown_inline",
        "mermaid",
        "regex",
        "vim",
        "lua",
      },
    },
    config = function(_, opts)
      require("nvim-treesitter.configs").setup(opts)
    end,
  },
}
