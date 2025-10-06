return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      -- Assurer que le parser pour mermaid est installé
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, { "mermaid" })
      end
    end,
  },
  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        { "<leader>m", group = "Mermaid" },
      },
    },
  },
  {
    "neovim/nvim-lspconfig", -- Juste pour ajouter le mapping, pas de dépendance directe
    config = function()
      -- La fonction qui génère et affiche l'aperçu
      local function PreviewMermaid()
        -- 1. Trouver le noeud treesitter pour le bloc de code mermaid
        local ts_utils = require("nvim-treesitter.ts_utils")
        local node = ts_utils.get_node_at_cursor()
        if not node then
          print("Aucun noeud treesitter trouvé.")
          return
        end

        local code_block_node
        -- Remonter l'arbre pour trouver le bloc de code
        while node do
          if node:type() == "code_fence_content" then
            local prev_sibling = node:prev_named_sibling()
            if prev_sibling and prev_sibling:type() == "fenced_code_block_info" then
               local lang = vim.treesitter.get_node_text(prev_sibling, 0)
               if lang == "mermaid" then
                 code_block_node = node
                 break
               end
            end
          end
          node = node:parent()
        end

        if not code_block_node then
          vim.notify("Placez votre curseur à l'intérieur d'un bloc de code Mermaid.", vim.log.levels.WARN)
          return
        end

        -- 2. Extraire le contenu du bloc
        local content = vim.treesitter.get_node_text(code_block_node, 0)

        -- 3. Définir les chemins pour les fichiers temporaires
        local tmp_dir = os.getenv("TMPDIR") or "/tmp"
        local input_file = tmp_dir .. "/mermaid_input.mmd"
        local output_file = tmp_dir .. "/mermaid_output.png"

        -- 4. Écrire le contenu dans un fichier temporaire
        local f_in = io.open(input_file, "w")
        if not f_in then
          vim.notify("Impossible de créer le fichier temporaire.", vim.log.levels.ERROR)
          return
        end
        f_in:write(content)
        f_in:close()

        -- 5. Exécuter mmdc pour générer l'image
        vim.notify("Génération de l'aperçu Mermaid...", vim.log.levels.INFO)
        local job_id = vim.fn.jobstart(string.format("mmdc -i %s -o %s -b transparent", input_file, output_file), {
          on_exit = function(_, exit_code)
            vim.schedule(function()
              if exit_code ~= 0 then
                vim.notify("Erreur lors de la génération du diagramme Mermaid.", vim.log.levels.ERROR)
                return
              end

              -- 6. Afficher l'image dans une fenêtre flottante avec kitty icat
              local buf = vim.api.nvim_create_buf(false, true)
              local win_width = vim.api.nvim_get_option("columns")
              local win_height = vim.api.nvim_get_option("lines")

              local float_width = math.floor(win_width * 0.8)
              local float_height = math.floor(win_height * 0.8)
              local left = math.floor((win_width - float_width) / 2)
              local top = math.floor((win_height - float_height) / 2)

              local win = vim.api.nvim_open_win(buf, true, {
                relative = "editor",
                width = float_width,
                height = float_height,
                col = left,
                row = top,
                style = "minimal",
                border = "single",
              })

              vim.fn.termopen(string.format("kitty +kitten icat --align=center --place=%dx%d@0x0 %s", float_width, float_height, output_file))

              vim.api.nvim_buf_set_keymap(buf, "n", "q", "<Cmd>close<CR>", { noremap = true, silent = true })

              -- Nettoyage après la fermeture de la fenêtre
              vim.api.nvim_win_set_buf(win, buf)
              vim.api.nvim_exec_autocmds("User", { pattern = "MermaidPreviewClosed", modeline = false })
              vim.api.nvim_create_autocmd("WinClosed", {
                buffer = buf,
                once = true,
                callback = function()
                  os.remove(input_file)
                  os.remove(output_file)
                end,
              })
            end)
          end,
        })
      end

      vim.keymap.set("n", "<leader>mp", PreviewMermaid, { desc = "Aperçu du diagramme Mermaid" })
    end,
  },
}