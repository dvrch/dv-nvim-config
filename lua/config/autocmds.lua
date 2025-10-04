-- ~/.config/nvim/lua/config/autocmds.lua
-- Automatic startup sequence

local api = vim.api

local M = {}

M.setup = function()
  -- Function to execute the startup sequence logic
  local function run_startup_sequence()
    local ok, err = pcall(function()
          -- 1. Diviser la fenêtre verticalement
          vim.cmd("vsplit")

          -- 2. Lancer Gemini dans la nouvelle fenêtre
          vim.cmd("terminal gemini")
          local width = math.floor(vim.fn.winwidth(0) / 3) 
          
          vim.cmd(width .. "split")
          vim.cmd("terminal")
        end)

        if not ok then
          vim.notify("Erreur dans le script de démarrage: " .. tostring(err), vim.log.levels.ERROR, { title = "Neovim Startup" })
        end
  end

  -- Autocommand for VimEnter (runs on startup)
  api.nvim_create_autocmd("VimEnter", {
    pattern = "*",
    group = api.nvim_create_augroup("user_startup", { clear = true }),
    callback = function()
      vim.schedule(run_startup_sequence) -- Call the function
    end,
  })

  -- Neovim command to run the startup sequence manually
  vim.api.nvim_create_user_command("RunStartupSequence", run_startup_sequence, {
    desc = "Manually run the custom startup sequence",
    force = true, -- Allow overriding existing commands
  })

  -- Key mapping for the command (e.g., <leader>ss for Startup Sequence)
  vim.keymap.set("n", "<leader>ss", ":RunStartupSequence<CR>", {
    desc = "Run custom startup sequence",
  })
end

M.setup()

return M
