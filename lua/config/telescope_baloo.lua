local M = {}

M.search = function(opts)
  opts = opts or {}
  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local action_state = require("telescope.actions.state")
  local actions = require("telescope.actions")

  pickers.new(opts, {
    prompt_title = "KRunner System Search (Baloo)",
    finder = finders.new_async_job({
      command_generator = function(prompt)
        if not prompt or prompt == "" then
          return nil
        end
        return { "baloosearch6", "--limit", "200", prompt }
      end,
      entry_maker = function(entry)
        if not entry or entry == "" then return nil end
        -- Enlever d'éventuels retours à la ligne
        entry = entry:gsub("[\n\r]", "")
        return {
          value = entry,
          display = entry,
          ordinal = entry,
          path = entry,
        }
      end,
    }),
    previewer = conf.file_previewer(opts),
    sorter = conf.file_sorter(opts),
  }):find()
end

return M
