return {
  {
    "jalvesaq/zotcite",
    enabled = function()
      -- Vérification de python3 et installation si nécessaire
      if vim.fn.executable("python3") == 0 then
        vim.notify("Installation de python3...", vim.log.levels.INFO)
        vim.fn.system("sudo apt-get update && sudo apt-get install -y python3 python3-pip")
      end
      if vim.fn.executable("pip3") == 1 then
        vim.fn.system("pip3 install --user pybtex")
      end
      return true
    end,
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      vim.g.zotero_sql_path = "/home/dv/snap/zotero-snap/common/Zotero/zotero.sqlite"
      vim.g.zotcite_conceallevel = 2
      
      local function open_zotero()
        vim.fn.system("zotero &")
      end
      
      vim.keymap.set("n", "<leader>zc", open_zotero, { desc = "Open Zotero" })
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