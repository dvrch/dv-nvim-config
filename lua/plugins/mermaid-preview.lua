return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "markdown",
        "mermaid",
      },
    },
  },
  {
    "edluffy/hologram.nvim",
    config = function()
      require('hologram').setup{
        auto_display = true
      }
    end
  },
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = function()
      vim.fn["mkdp#util#install"]()
    end,
    init = function()
      vim.g.mkdp_filetypes = { "markdown" }
      vim.g.mkdp_auto_start = 0
      vim.g.mkdp_open_to_the_world = 0
      vim.g.mkdp_open_ip = "127.0.0.1"
      vim.g.mkdp_port = "8888"
      vim.g.mkdp_echo_preview_url = true
      vim.g.mkdp_preview_options = {
        mermaid = { theme = "default" }
      }
      vim.g.mkdp_markdown_css = vim.fn.expand("~/.config/nvim/colors/markdown.css")
      vim.g.mkdp_page_title = "${name}"
      vim.g.mkdp_preview_options.disable_sync_scroll = 1
    end,
    keys = {
      { "<leader>mp", "<cmd>split | terminal mmdc -i % -o %.png && hologram display %.png<cr>", desc = "Aperçu Mermaid (Kitty)" },
    },
  }
}