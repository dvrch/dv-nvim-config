return {
  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        { "<leader>r", group = "run" },
      },
    }
  },
  {
    "stevearc/overseer.nvim",
    opts = {},
    config = function()
      -- Définition de la commande <leader>rr
      vim.keymap.set("n", "<leader>rr", function()
        local file = vim.fn.expand("%:p")
        -- Commande Python qui envoie le fichier au socket Houdini
        local cmd = "python3 /home/kd/Documents/proudini/P26_1/scripts/python/send_to_houdini.py " .. file
        
        -- Ouvre un split en bas (terminal)
        vim.cmd("belowright split | terminal " .. cmd)
        -- Ou plus propre avec overseer si on voulait, mais restons simple
      end, { desc = "Run Python in Houdini (Socket)" })
      
      -- Optionnel : <leader>rh pour lancer hcommand simple
      vim.keymap.set("n", "<leader>rh", function()
        local file = vim.fn.expand("%:p")
        -- hcommand sur le port 24789
        local cmd = "/opt/hfs21.0.440/bin/hcommand 24789 \"python " .. file .. "\""
        vim.cmd("belowright split | terminal " .. cmd)
      end, { desc = "Run in Houdini (Legacy hcommand)" })
    end,
  }
}
