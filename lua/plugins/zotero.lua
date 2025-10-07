return {
  {
    "jalvesaq/zotcite",
    build = function()
      -- Installation automatique des dépendances Python
      vim.fn.system("sudo apt-get update && sudo apt-get install -y python3 python3-pip && pip3 install pybtex")
    end,
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      vim.g.zotero_sql_path = "/home/dv/snap/zotero-snap/common/Zotero/zotero.sqlite"
      vim.g.zotcite_conceallevel = 2
      
      -- Fonction directe pour ouvrir Zotero
      local function open_zotero()
        vim.fn.system("zotero &")
      end
      
      -- Raccourci direct
      vim.keymap.set("n", "<leader>zc", open_zotero, { desc = "Open Zotero" })
      
      -- Commandes zotcite alternatives
      vim.keymap.set("n", "<leader>zi", function()
        if vim.fn.exists(":ZCitation") == 2 then
          vim.cmd("ZCitation")
        elseif vim.fn.exists(":Zotcite") == 2 then
          vim.cmd("Zotcite")
        else
          print("Zotcite commands not available")
        end
      end, { desc = "Insert Citation" })
    end,
  }
}