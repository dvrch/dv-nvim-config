return {
  "pieces-app/plugin_neovim",
  build = function()
    -- Set the correct python path (adapt this to your venv path)
    vim.g.python3_host_prog = "/home/kd/nvim-venv/bin/python" -- Replace with your venv's Python path
    vim.notify("Pieces: Build process started for local plugin...", vim.log.levels.INFO)
    local python_path = vim.g.python3_host_prog
    local pip_path = python_path:gsub("bin/python$", "bin/pip")
    if pip_path == python_path then -- Au cas où le remplacement échoue
        pip_path = python_path:gsub("python$", "pip")
    end

    local install_cmd = pip_path .. " install --upgrade pynvim pieces_os_client pyyaml"
    vim.notify("Pieces: Using pip command: " .. install_cmd, vim.log.levels.INFO)

    local result = vim.fn.system(install_cmd)
    if vim.v.shell_error ~= 0 then
      vim.notify("Pieces: Failed to install/upgrade python packages. Please check your pip.", vim.log.levels.ERROR)
      vim.notify("pip output: " .. result, vim.log.levels.INFO)
      return
    end
    vim.notify("Pieces: Python packages installed/updated successfully.", vim.log.levels.INFO)

    -- Mettre à jour les plugins distants
    vim.notify("Pieces: Running :UpdateRemotePlugins...", vim.log.levels.INFO)
    vim.cmd("UpdateRemotePlugins")
    vim.notify("Pieces: UpdateRemotePlugins command executed. You MUST restart Neovim now.", vim.log.levels.WARN)
  end,
  config = function()
    vim.g.python3_host_prog = "/home/kd/nvim-venv/bin/python"
  end,
  health = function()
    local status = true
    local messages = {}

    local ok, pieces = pcall(require, "pieces")
    if ok then
      table.insert(messages, {
        msg = "✅ pieces.nvim est chargé.",
        icon = "",
        highlight = "HealthSuccess",
      })
    else
      status = false
      table.insert(messages, {
        msg = "❌ pieces.nvim n'a pas pu être chargé. Erreur: " .. pieces,
        icon = "",
        highlight = "HealthError",
      })
      table.insert(messages, {
        msg = "💡 Assurez-vous que le plugin est correctement installé et que son chemin est correct.",
        icon = "",
        highlight = "HealthWarning",
      })
    end

    return status, messages
  end,
  -- If you want to specify a branch, you can do it like this:
  -- branch = "main",
}