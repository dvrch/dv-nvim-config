return {
  "folke/noice.nvim",
  opts = {
    notify = {
      enabled = false,
    },
    lsp = {
      hover = {
        enabled = false,
      },
      signature = {
        enabled = false,
      },
      override = {
        ["vim.lsp.util.convert_input_to_markdown_lines"] = { enabled = false },
        ["vim.lsp.util.stylize_markdown"] = { enabled = false },
      },
    },
  },
}
