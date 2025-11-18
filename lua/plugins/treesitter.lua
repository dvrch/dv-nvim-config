return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  opts = {
    ensure_installed = {
      -- Liste consolidée de tous vos fichiers de configuration
      "bash",
      "cmake",
      "cpp",
      "latex",
      "lua",
      "markdown",
      "markdown_inline",
      "mermaid",
      "python",
      "svelte",
      "vimdoc",
      "yaml",
    },
    -- Activer la coloration syntaxique et l'indentation
    highlight = { enable = true },
    indent = { enable = true },
  },
}