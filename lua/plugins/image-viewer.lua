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
          -- 🛠️ RÉSOLVEUR ULTRA-ROBUSTE POUR OBSIDIAN (ESPACES + CHEMINS LONGS)
          resolve_image_path = function(document_path, image_path, _)
            -- Traitement des espaces et encodage (Obsidian met souvent des %20)
            local clean_path = image_path:gsub("%%20", " ")
            
            -- 1. Si c'est déjà un chemin absolu direct
            if clean_path:sub(1, 1) == "/" and vim.loop.fs_stat(clean_path) then
                return clean_path
            end
            
            local current_dir = vim.fn.fnamemodify(document_path, ":h")
            
            -- 2. Trouver la racine du coffre Obsidian (vault root)
            local vault_root = current_dir
            while vault_root ~= "/" do
              if vim.loop.fs_stat(vault_root .. "/.obsidian") then
                break
              end
              vault_root = vim.fn.fnamemodify(vault_root, ":h")
            end
            if vault_root == "/" then vault_root = current_dir end

            -- 3. Liste des endroits probables (ordre de priorité)
            local candidates = {
              current_dir .. "/" .. clean_path,            -- À côté du fichier
              vault_root .. "/" .. clean_path,             -- Racine du coffre
              vault_root .. "/pieces_j/" .. clean_path,    -- Dossier custom
              vault_root .. "/attachments/" .. clean_path, -- Dossier standard
            }
            
            for _, path in ipairs(candidates) do
              if vim.loop.fs_stat(path) then
                return path
              end
            end
            
            -- 4. Recherche de "Dernière chance" : si le fichier existe PARTOUT dans le coffre
            -- (On utilise 'find' pour gérer les noms avec espaces et sous-dossiers mal connus)
            local find_cmd = string.format("find %s -name %s -type f -print -quit", 
              vim.fn.shellescape(vault_root), 
              vim.fn.shellescape(clean_path))
            local found_path = vim.fn.system(find_cmd):gsub("\n", "")
            
            if found_path ~= "" then
              return found_path
            end

            return clean_path
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