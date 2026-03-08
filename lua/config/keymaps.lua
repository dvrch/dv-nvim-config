-- This file is for custom keymaps
-- You can create new keymaps here

-- Open the default LazyVim dashboard
-- Shortcut <leader>db
vim.keymap.set("n", "<leader>db", ":Alpha<CR>", { desc = "Open Dashboard" })

-- Open a terminal
vim.keymap.set("n", "<leader>t", ":terminal<CR>", { desc = "Open Terminal" })

-- Condition de démarrage pour Gemini (Désactivé par défaut, mais mémorisé)
local gemini_cfg = vim.fn.stdpath("data") .. "/gemini_autolaunch.txt"
if vim.fn.filereadable(gemini_cfg) == 1 then
  vim.g.gemini_autolaunch = vim.fn.readfile(gemini_cfg)[1] == "true"
else
  -- Valeur par défaut si aucun fichier : true (activé par défaut)
  vim.g.gemini_autolaunch = true
end

-- Toggle Gemini auto-launch avec mémorisation
vim.keymap.set("n", "<leader>gT", function()
  vim.g.gemini_autolaunch = not vim.g.gemini_autolaunch
  vim.fn.writefile({ tostring(vim.g.gemini_autolaunch) }, gemini_cfg)
  local status = vim.g.gemini_autolaunch and "ACTIVÉ (au prochain lancement)" or "DÉSACTIVÉ"
  vim.notify("🤖 Gemini auto-launch: " .. status, vim.log.levels.INFO)
end, { desc = "Toggle Gemini Auto-Launch" })

-- Open Gemini CLI manually (leader gc)
vim.keymap.set("n", "<leader>gc", ":tabnew | terminal gemini<CR>", { desc = "Open Gemini CLI" })

-- Open current file in VSCode (leader ov)
vim.keymap.set("n", "<leader>ov", function()
  local file_path = vim.fn.expand("%:p")
  if file_path and file_path ~= "" then
    vim.fn.jobstart({ "code", file_path }, { detach = true })
    vim.notify("📝 VSCode: " .. vim.fn.pathshorten(file_path), vim.log.levels.INFO)
  else
    vim.notify("Aucun fichier à ouvrir.", vim.log.levels.WARN)
  end
end, { desc = "Open in VSCode" })

-- Ouvrir dans Zed (leader oz) - Fix avec os.execute
vim.keymap.set("n", "<leader>oz", function()
  local file_path = vim.fn.expand("%:p")
  if file_path and file_path ~= "" then
    local cmd = "nohup /home/kd/.local/zed.app/bin/zed " .. vim.fn.shellescape(file_path) .. " > /dev/null 2>&1 &"
    os.execute(cmd)
    vim.notify("⚡ Zed (Ouverture forcée): " .. vim.fn.pathshorten(file_path))
  else
    vim.notify("Aucun fichier à ouvrir.", vim.log.levels.WARN)
  end
end, { desc = "Open in Zed" })

-- Ouvrir dans Obsidian Standard (leader oo)
vim.keymap.set("n", "<leader>oo", function()
  local file_path = vim.fn.expand("%:p")
  if file_path and file_path ~= "" then
    local cmd = "nohup obsidian " .. vim.fn.shellescape(file_path) .. " > /dev/null 2>&1 &"
    os.execute(cmd)
    vim.notify("💎 Obsidian: " .. vim.fn.pathshorten(file_path))
  end
end, { desc = "Open in Obsidian" })

-- Ouvrir dans Obsidian LITE (leader oL) - SANS plugins tiers
vim.keymap.set("n", "<leader>oL", function()
  local file_path = vim.fn.expand("%:p")
  if file_path == "" then return end
  
  -- 1. Trouver la racine du coffre (vault root)
  local vault_root = vim.fn.fnamemodify(file_path, ":h")
  while vault_root ~= "/" do
    if vim.fn.isdirectory(vault_root .. "/.obsidian") == 1 then
      break
    end
    vault_root = vim.fn.fnamemodify(vault_root, ":h")
  end

  if vault_root == "/" then
    vim.notify("❌ Racine du coffre Obsidian non trouvée.", vim.log.levels.ERROR)
    return
  end

  -- 2. Créer un coffre "miroir" LITE (Shadow Vault)
  local lite_vault = vim.fn.expand("~/.obsidian-lite-vault")
  vim.fn.system("rm -rf " .. vim.fn.shellescape(lite_vault))
  vim.fn.mkdir(lite_vault, "p")

  -- 3. Symlinker tout SAUF le dossier .obsidian
  -- Cela force Obsidian à ouvrir le dossier comme un nouveau coffre sans plugins
  local items = vim.fn.glob(vault_root .. "/*", false, true)
  for _, item in ipairs(items) do
    local name = vim.fn.fnamemodify(item, ":t")
    if name ~= ".obsidian" then
      vim.fn.system(string.format("ln -s %s %s/%s", vim.fn.shellescape(item), vim.fn.shellescape(lite_vault), vim.fn.shellescape(name)))
    end
  end

  -- 4. Lancer Obsidian sur ce coffre miroir
  local relative_file = file_path:sub(#vault_root + 2)
  local cmd = string.format("nohup obsidian %s/%s > /dev/null 2>&1 &", vim.fn.shellescape(lite_vault), vim.fn.shellescape(relative_file))
  os.execute(cmd)
  
  vim.notify("💎 Obsidian LITE (Safe Mode) : Coffre miroir créé sans plugins.", vim.log.levels.INFO)
end, { desc = "Open in Obsidian LITE (No Plugins)" })

-- Locate current file in explorer
vim.keymap.set("n", "<leader>oe", function()
  local file = vim.fn.expand("%:p")
  if file and file ~= "" then
    -- Use os.execute with nohup to ensure it detaches correctly
    local cmd = string.format("nohup /usr/bin/dolphin --select %s >/dev/null 2>&1 &", vim.fn.shellescape(file))
    os.execute(cmd)
    vim.notify("Dolphin (Focus) : " .. vim.fn.pathshorten(file), vim.log.levels.INFO)
  end
end, { desc = "Locate in Dolphin Explorer" })

-- Open current directory in explorer
vim.keymap.set("n", "<leader>od", function()
  local dir = vim.fn.expand("%:p:h")
  if dir and dir ~= "" then
    local cmd = string.format("nohup /usr/bin/dolphin %s >/dev/null 2>&1 &", vim.fn.shellescape(dir))
    os.execute(cmd)
    vim.notify("Dolphin (Dossier) : " .. vim.fn.pathshorten(dir), vim.log.levels.INFO)
  end
end, { desc = "Open Directory in Dolphin" })

-- Open file under cursor with system default
vim.keymap.set("n", "<leader>ox", function()
  local file = vim.fn.expand("<cfile>")
  if file and file ~= "" then
    vim.fn.jobstart({ "xdg-open", file }, { detach = true })
  end
end, { desc = "Open with System Default" })

-- Find recent projects (workspaces) using telescope-frecency
-- Shortcut <leader>pw
vim.keymap.set("n", "<leader>pw", "<cmd>Telescope frecency workspace=CWD<CR>", { desc = "[P]roject [W]orkspaces (frecency)" })