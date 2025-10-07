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
      { "<leader>mp", function()
        local diagram = vim.fn.expand("%:p")
        local temp_buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_command("vsplit")
        vim.api.nvim_win_set_buf(0, temp_buf)
        vim.api.nvim_buf_set_option(temp_buf, "buftype", "nofile")
        vim.api.nvim_buf_set_option(temp_buf, "bufhidden", "wipe")
        vim.fn.jobstart({"curl", "-s", "--data-urlencode", "diagram@" .. diagram, "https://kroki.io/mermaid/svg"}, {
          stdout_buffered = true,
          on_stdout = function(_, data)
            if data then
              vim.api.nvim_buf_set_lines(temp_buf, 0, -1, false, data)
            end
          end
        })
      end, desc = "Aperçu Mermaid (Buffer)" },
    },
  }
}