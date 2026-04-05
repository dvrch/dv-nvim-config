local M = {}

M.ns_cell = vim.api.nvim_create_namespace("jupyter_ghost_lines")

-- 🎨 CONFIGURATION DES COULEURS (Aesthetic VSCode)
local function setup_hls()
  vim.api.nvim_set_hl(0, "JupyterMdHeader", { fg = "#FFD700", bold = true, default = true })
  vim.api.nvim_set_hl(0, "JupyterCodeHeader", { fg = "#FF8C00", bold = true, default = true })
  vim.api.nvim_set_hl(0, "JupyterFooter", { fg = "#646464", italic = true, default = true })
end

--- @param buf number | nil
--- @return boolean
function M.is_enabled(buf)
  buf = buf or vim.api.nvim_get_current_buf()
  local val = vim.b[buf].jupyter_decorate_enabled
  -- Par défaut, activé pour ipynb, désactivé ailleurs
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
  -- On ne nettoie que si nécessaire ou on gère par extmark ID pour éviter le flickering
  vim.api.nvim_buf_clear_namespace(buf, M.ns_cell, 0, -1)

  if not M.is_enabled(buf) then return end

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

  -- Masquage de la ligne originale (pour un look "ghost" permanent)
  local function mask_line(idx, line)
    local mask = string.rep(" ", vim.fn.strdisplaywidth(line))
    vim.api.nvim_buf_set_extmark(buf, M.ns_cell, idx, 0, {
      virt_text = { { mask, "Conceal" } },
      virt_text_pos = "overlay",
      priority = 2100,
    })
  end

  for i, line in ipairs(lines) do
    local idx = i - 1
    if not is_py then
      -- ═══════ VUE MARKDOWN ═══════
      if line:find("#region", 1, true) or line:find("<!-- #region", 1, true) then
        mask_line(idx, line)
        vim.api.nvim_buf_set_extmark(buf, M.ns_cell, idx, 0, {
          virt_lines = { { { "📝 ╔══ CELLULE MARKDOWN ══════════════════════════════════════════╗", "JupyterMdHeader" } } },
          virt_lines_above = true, priority = 2000 })

      elseif line:find("#endregion", 1, true) or line:find("<!-- #endregion", 1, true) then
        mask_line(idx, line)
        vim.api.nvim_buf_set_extmark(buf, M.ns_cell, idx, 0, {
          virt_lines = { { { "   ╚══ FIN CELLULE MARKDOWN ═════════════════════════════════════╝", "JupyterFooter" } } },
          virt_lines_above = false, priority = 2000 })

      elseif line:find("```python", 1, true) then
        mask_line(idx, line)
        vim.api.nvim_buf_set_extmark(buf, M.ns_cell, idx, 0, {
          virt_lines = { { { "⚡ ╔══ CELLULE CODE ═══════════════════════════════════════════════╗", "JupyterCodeHeader" } } },
          virt_lines_above = true, priority = 2000 })

      elseif line == "```" or line:find("^%s*```%s*$") then
        local found_start = false
        for j = i - 1, 1, -1 do
          if lines[j]:find("```python", 1, true) then found_start = true break end
          if lines[j]:find("```", 1, true) then break end
        end
        if found_start then
          mask_line(idx, line)
          vim.api.nvim_buf_set_extmark(buf, M.ns_cell, idx, 0, {
            virt_lines = { { { "   ╚══ FIN CELLULE CODE ══════════════════════════════════════════╝", "JupyterFooter" } } },
            virt_lines_above = false, priority = 2000 })
        end
      end

    else
      -- ═══════ VUE PYTHON ═══════
      if line:find("# %% [markdown]", 1, true) then
        mask_line(idx, line)
        if i > 1 then
          vim.api.nvim_buf_set_extmark(buf, M.ns_cell, idx, 0, {
            virt_lines = { { { "   ╚══ FIN CELLULE ═══════════════════════════════════════════════╝", "JupyterFooter" } } },
            virt_lines_above = true, priority = 2050 })
        end
        vim.api.nvim_buf_set_extmark(buf, M.ns_cell, idx, 0, {
          virt_lines = { { { "📝 ╔══ CELLULE MARKDOWN ══════════════════════════════════════════╗", "JupyterMdHeader" } } },
          virt_lines_above = false, priority = 2000 })

      elseif line:find("# %%", 1, true) and not line:find("markdown", 1, true) then
        mask_line(idx, line)
        if i > 1 then
          vim.api.nvim_buf_set_extmark(buf, M.ns_cell, idx, 0, {
            virt_lines = { { { "   ╚══ FIN CELLULE ═══════════════════════════════════════════════╝", "JupyterFooter" } } },
            virt_lines_above = true, priority = 2050 })
        end
        vim.api.nvim_buf_set_extmark(buf, M.ns_cell, idx, 0, {
          virt_lines = { { { "⚡ ╔══ CELLULE CODE ═══════════════════════════════════════════════╗", "JupyterCodeHeader" } } },
          virt_lines_above = false, priority = 2000 })
      end
    end
  end
end

return M
