return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  opts = function(_, opts)
    -- Ensure parsers are installed
    if type(opts.ensure_installed) == "table" then
      vim.list_extend(opts.ensure_installed, { "markdown", "markdown_inline", "vimdoc", "lua", "python" })
    end
  end,
}
