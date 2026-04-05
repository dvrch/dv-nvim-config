local M = {}

M.ns_cell = vim.api.nvim_create_namespace("jupyter_ghost_lines")

-- 🎨 CONFIGURATION DES COULEURS ELITE
local function setup_hls()
  vim.api.nvim_set_hl(0, "JupyterMdHeader", { fg = "#ffcc00", bold = true, default = true })
  vim.api.nvim_set_hl(0, "JupyterCodeHeader", { fg = "#ff6600", bold = true, default = true })
  vim.api.nvim_set_hl(0, "JupyterFooter", { fg = "#555555", italic = true, default = true })
  
  -- Récupération dynamique de la couleur de fond (pour rendre le curseur aveugle au texte caché)
  local normal_hl = vim.api.nvim_get_hl(0, { name = "Normal" })
  local bg_color = normal_hl.bg or "NONE"
  if type(bg_color) == "number" then bg_color = string.format("#%06x", bg_color) end
  vim.api.nvim_set_hl(0, "JupyterHidden", { fg = bg_color, bg = bg_color, default = true })
end

--- @param buf number | nil
--- @return boolean
function M.is_enabled(buf)
  buf = buf or vim.api.nvim_get_current_buf()
  local val = vim.b[buf].jupyter_decorate_enabled
  if val == nil then
    local name = vim.api.nvim_buf_get_name(buf)
    return name:match("%.ipynb$") ~= nil
  end
  return val
end

--- @param buf number | nil
function M.toggle(buf)
  buf = buf or vim.api.nvim_get_current_buf()
  local new_state = not M.is_enabled(buf)
  vim.b[buf].jupyter_decorate_enabled = new_state
  
  if new_state then
    M.decorate(buf)
    vim.notify("🎨 Décorations Jupyter : ACTIVÉES", vim.log.levels.INFO)
  else
    vim.api.nvim_buf_clear_namespace(buf, M.ns_cell, 0, -1)
    vim.notify("🎨 Décorations Jupyter : DÉSACTIVÉES", vim.log.levels.WARN)
  end
end

--- @param buf number | nil
function M.decorate(buf)
  buf = buf or vim.api.nvim_get_current_buf()
  if not vim.api.nvim_buf_is_valid(buf) then return end
  
  setup_hls()
  vim.api.nvim_buf_clear_namespace(buf, M.ns_cell, 0, -1)

  if not M.is_enabled(buf) then return end

  vim.opt_local.conceallevel = 2
  vim.opt_local.concealcursor = "nvic"

  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  if #lines == 0 then return end

  -- ✅ DÉTECTION DU FORMAT
  local is_py = false
  for _, l in ipairs(lines) do
    if l:match("^# %%%%") or l:match("^# %% ") then
      is_py = true
      break
    end
  end

  local in_code = false

  -- Masquage OPAQUE (Adieu définitif Ghost lines & Cache-cache)
  local function hide_line(idx, line)
    -- Ne pas vérifier cursor_line : cela garantit la persistance visuelle
    local width = vim.fn.strdisplaywidth(line)
    if width == 0 then width = 1 end
    local mask = string.rep(" ", width + 10)
    vim.api.nvim_buf_set_extmark(buf, M.ns_cell, idx, 0, {
      virt_text = { { mask, "JupyterHidden" } },
      virt_text_pos = "overlay", priority = 5000,
      virt_text_hide = false,
    })
  end

  for i, line in ipairs(lines) do
    local idx = i - 1

    if not is_py then
      -- ═══════ VUE MARKDOWN ═══════
      if line:match("<!-- #region") or line:match("#region") then
        hide_line(idx, line)
        local title = line:gsub("<!%-%-%s*", ""):gsub("%s*%-%->", ""):gsub("#region%s*", "")
        title = title ~= "" and title:upper() or "MARKDOWN"
        vim.api.nvim_buf_set_extmark(buf, M.ns_cell, idx, 0, {
          virt_lines = { { 
            { "📝 ╔══ CELLULE " .. title .. " ", "JupyterMdHeader" },
            { string.rep("═", math.max(60 - #title - 8, 5)), "JupyterMdHeader" },
            { "╗", "JupyterMdHeader" }
          } },
          virt_lines_above = true, priority = 4900 })

      elseif line:match("<!-- #endregion") or line:match("#endregion") then
        hide_line(idx, line)
        vim.api.nvim_buf_set_extmark(buf, M.ns_cell, idx, 0, {
          virt_lines = { { 
            { "   ╚" .. string.rep("═", 5), "JupyterFooter" },
            { " FIN SECTION ", "JupyterFooter" }, 
            { string.rep("═", 49), "JupyterFooter" },
            { "╝", "JupyterFooter" }
          } },
          virt_lines_above = false, priority = 4900 })
      
      -- BLOCS DE CODE MD
      elseif line:match("^%s*```") or line:match("^%%%%%w+") then
        -- Pas de hide_line() ici pour les blocs ``` afin de les garder visibles/éditables
        if not in_code then
          local lang = line:match('languageId": "([^"]+)"') 
                       or line:match("^%s*```(%w+)") 
                       or line:match("^%%%%(%w+)") 
                       or "Python"
          lang = lang:gsub("^%w", string.upper)
          
          vim.api.nvim_buf_set_extmark(buf, M.ns_cell, idx, 0, {
            virt_lines = { { 
              { "⚡ ╔══ [ " .. lang .. " ] ", "JupyterCodeHeader" },
              { string.rep("═", 50), "JupyterCodeHeader" },
              { "╗", "JupyterCodeHeader" }
            } },
            virt_lines_above = true, priority = 4900 })
          in_code = true
        else
          vim.api.nvim_buf_set_extmark(buf, M.ns_cell, idx, 0, {
            virt_lines = { { 
              { "   ╚" .. string.rep("═", 5), "JupyterFooter" },
              { " FIN CELLULE CODE ", "JupyterFooter" },
              { string.rep("═", 45), "JupyterFooter" },
              { "╝", "JupyterFooter" }
            } },
            virt_lines_above = false, priority = 4900 })
          in_code = false
        end
      end

    else
      -- ═══════ VUE PYTHON ═══════
      if line:find("# %% [markdown]", 1, true) then
        hide_line(idx, line)
        if i > 1 then
          vim.api.nvim_buf_set_extmark(buf, M.ns_cell, idx, 0, {
            virt_lines = { { 
              { "   ╚" .. string.rep("═", 5), "JupyterFooter" },
              { " FIN CELLULE ", "JupyterFooter" },
              { string.rep("═", 50), "JupyterFooter" },
              { "╝", "JupyterFooter" }
            } },
            virt_lines_above = true, priority = 4950 })
        end
        vim.api.nvim_buf_set_extmark(buf, M.ns_cell, idx, 0, {
          virt_lines = { { 
            { "📝 ╔══ CELLULE MARKDOWN ", "JupyterMdHeader" },
            { string.rep("═", 43), "JupyterMdHeader" },
            { "╗", "JupyterMdHeader" }
          } },
          virt_lines_above = false, priority = 4900 })

      elseif line:find("# %%", 1, true) and not line:find("markdown", 1, true) then
        hide_line(idx, line)
        if i > 1 then
          vim.api.nvim_buf_set_extmark(buf, M.ns_cell, idx, 0, {
            virt_lines = { { 
              { "   ╚" .. string.rep("═", 5), "JupyterFooter" },
              { " FIN CELLULE ", "JupyterFooter" },
              { string.rep("═", 50), "JupyterFooter" },
              { "╝", "JupyterFooter" }
            } },
            virt_lines_above = true, priority = 4950 })
        end
        vim.api.nvim_buf_set_extmark(buf, M.ns_cell, idx, 0, {
          virt_lines = { { 
            { "⚡ ╔══ CELLULE CODE ", "JupyterCodeHeader" },
            { string.rep("═", 47), "JupyterCodeHeader" },
            { "╗", "JupyterCodeHeader" }
          } },
          virt_lines_above = false, priority = 4900 })
      end
    end
  end
end

return M
