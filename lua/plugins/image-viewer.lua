return {
  {
    -- Binding Lua pour Imagemagick (Indispensable pour image.nvim)
    "vhyrro/luarocks.nvim",
    priority = 1001,
    opts = {
      rocks = { "magick" },
    },
  },
  {
    "3rd/image.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "vhyrro/luarocks.nvim",
    },
    opts = {
      backend = "kitty",
      integrations = {
        markdown = {
          enabled = true,
          clear_in_insert_mode = false,
          download_remote_images = true,
          only_render_image_at_cursor = false,
          filetypes = { "markdown", "vimwiki" },
          -- Support pour les liens Obsidian ![[Pasted image ...]]
          resolve_image_path = function(document_path, image_path, _)
            local expanded_image_path = vim.fn.expand(image_path)
            if vim.loop.fs_stat(expanded_image_path) then
                return expanded_image_path
            end
            
            local current_dir = vim.fn.fnamemodify(document_path, ":h")
            local search_paths = {
              current_dir .. "/" .. image_path,
              current_dir .. "/attachments/" .. image_path,
              current_dir .. "/assets/" .. image_path,
            }
            
            for _, path in ipairs(search_paths) do
              if vim.loop.fs_stat(path) then
                return path
              end
            end
            return image_path
          end,
        },
        mermaid = {
          enabled = true,
          clear_in_insert_mode = false,
          filetypes = { "markdown", "quarto" },
        },
      },
      max_width = 100,
      max_height = 20,
      max_width_window_percentage = nil,
      max_height_window_percentage = 40,
      window_overlap_clear_enabled = false,
      window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "" },
      editor_only_render_when_focused = false,
      tmux_show_boundary = false,
    },
  },
}