local M = {}

M.ns_cell = vim.api.nvim_create_namespace("jupyter_ghost_lines")

-- 🎨 CONFIGURATION DES COULEURS (Aesthetic VSCode)
local function setup_hls()
  vim.api.nvim_set_hl(0, "JupyterMdHeader", { fg = "#FFD700", bold = true, default = true })
  vim.api.nvim_set_hl(0, "JupyterCodeHeader", { fg = "#FF8C00", bold = true, default = true })
  vim.api.nvim_set_hl(0, "JupyterFooter", { fg = "#646464", italic = true, default = true })
end

--- @param buf number | nil
function M.decorate(buf)
  buf = buf or vim.api.nvim_get_current_buf()
  if not vim.api.nvim_buf_is_valid(buf) then return end
  
  setup_hls()
  vim.api.nvim_buf_clear_namespace(buf, M.ns_cell, 0, -1)

  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  if #lines == 0 then return end

  -- ✅ DÉTECTION DU FORMAT (PYTHON / MARKDOWN)
  local is_py = false
  for _, l in ipairs(lines) do
    if l:match("^# %%%%") or l:match("^# %% ") then
      is_py = true
      break
    end
  end

  for i, line in ipairs(lines) do
    if not is_py then
      -- ═══════ VUE MARKDOWN ═══════
      if line:find("#region", 1, true) or line:find("<!-- #region", 1, true) then
        vim.api.nvim_buf_set_extmark(buf, M.ns_cell, i - 1, 0, {
          virt_lines = { { { "📝 ╔══ CELLULE MARKDOWN ══════════════════════════════════════════╗", "JupyterMdHeader" } } },
          virt_lines_above = true, priority = 2000 })

      elseif line:find("#endregion", 1, true) or line:find("<!-- #endregion", 1, true) then
        vim.api.nvim_buf_set_extmark(buf, M.ns_cell, i - 1, 0, {
          virt_lines = { { { "   ╚══ FIN CELLULE MARKDOWN ═════════════════════════════════════╝", "JupyterFooter" } } },
          virt_lines_above = false, priority = 2000 })

      elseif line:find("```python", 1, true) then
        vim.api.nvim_buf_set_extmark(buf, M.ns_cell, i - 1, 0, {
          virt_lines = { { { "⚡ ╔══ CELLULE CODE ═══════════════════════════════════════════════╗", "JupyterCodeHeader" } } },
          virt_lines_above = true, priority = 2000 })

      elseif line == "```" or line:find("^%s*```%s*$") then
        -- On vérifie s'il y avait un ```python au-dessus
        -- (Simple scan inverse pour la robustesse)
        local found_start = false
        for j = i - 1, 1, -1 do
          if lines[j]:find("```python", 1, true) then found_start = true break end
          if lines[j]:find("```", 1, true) then break end
        end
        if found_start then
          vim.api.nvim_buf_set_extmark(buf, M.ns_cell, i - 1, 0, {
            virt_lines = { { { "   ╚══ FIN CELLULE CODE ══════════════════════════════════════════╝", "JupyterFooter" } } },
            virt_lines_above = false, priority = 2000 })
        end
      end

    else
      -- ═══════ VUE PYTHON (PERCENT) ═══════
      if line:find("# %% [markdown]", 1, true) then
        if i > 1 then
          vim.api.nvim_buf_set_extmark(buf, M.ns_cell, i - 1, 0, {
            virt_lines = { { { "   ╚══ FIN CELLULE ═══════════════════════════════════════════════╝", "JupyterFooter" } } },
            virt_lines_above = true, priority = 2000 })
        end
        vim.api.nvim_buf_set_extmark(buf, M.ns_cell, i - 1, 0, {
          virt_lines = { { { "📝 ╔══ CELLULE MARKDOWN ══════════════════════════════════════════╗", "JupyterMdHeader" } } },
          virt_lines_above = false, priority = 1999 })

      elseif line:find("# %%", 1, true) and not line:find("markdown", 1, true) then
        if i > 1 then
          vim.api.nvim_buf_set_extmark(buf, M.ns_cell, i - 1, 0, {
            virt_lines = { { { "   ╚══ FIN CELLULE ═══════════════════════════════════════════════╝", "JupyterFooter" } } },
            virt_lines_above = true, priority = 2000 })
        end
        vim.api.nvim_buf_set_extmark(buf, M.ns_cell, i - 1, 0, {
          virt_lines = { { { "⚡ ╔══ CELLULE CODE ═══════════════════════════════════════════════╗", "JupyterCodeHeader" } } },
          virt_lines_above = false, priority = 1999 })
      end
    end
  end
end

return M
