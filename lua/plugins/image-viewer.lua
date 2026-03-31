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
          -- RÉSOLVEUR DE CHEMINS UNIVERSEL (Obsidian, Espaces, Courts, Longs)
          resolve_image_path = function(document_path, image_path, _)
            local clean_path = image_path:gsub("%%20", " ")
            if clean_path:sub(1, 1) == "/" and vim.loop.fs_stat(clean_path) then
                return clean_path
            end
            
            local current_dir = vim.fn.fnamemodify(document_path, ":h")
            
            -- Trouver le coffre Obsidian
            local vault_root = current_dir
            while vault_root ~= "/" do
              if vim.loop.fs_stat(vault_root .. "/.obsidian") then break end
              vault_root = vim.fn.fnamemodify(vault_root, ":h")
            end
            if vault_root == "/" then vault_root = current_dir end

            -- Recherche par priorité
            local candidates = {
              current_dir .. "/" .. clean_path,
              vault_root .. "/" .. clean_path,
              vault_root .. "/pieces_j/" .. clean_path,
              vault_root .. "/attachments/" .. clean_path,
            }
            for _, path in ipairs(candidates) do
              if vim.loop.fs_stat(path) then return path end
            end
            
            -- "Dernière chance" : recherche globale ultrarapide
            local find_cmd = string.format("find %s -name %s -type f -print -quit", 
              vim.fn.shellescape(vault_root), 
              vim.fn.shellescape(clean_path))
            local found_path = vim.fn.system(find_cmd):gsub("\n", "")
            return found_path ~= "" and found_path or clean_path
          end,
        },
        mermaid = {
          enabled = true,
          clear_in_insert_mode = false,
          filetypes = { "markdown", "quarto" },
          -- Forçage du moteur de rendu avec les nouveaux composants installés
          puppeteer_args = { "--no-sandbox" },
          executable_path = "mmdc",
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