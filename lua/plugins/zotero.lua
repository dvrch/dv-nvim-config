return {
  {
    "jalvesaq/zotcite",
    enabled = false,
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