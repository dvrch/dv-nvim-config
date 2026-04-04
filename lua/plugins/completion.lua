return {
  -- 🧬 CENTRALIZED COMPLETION CONFIG (Unified AI & Houdini)
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-omni",
      "zbirenbaum/copilot-cmp",
    },
    opts = function(_, opts)
      local cmp = require("cmp")
      
      -- On définit les sources de manière plate pour qu'elles cohabitent
      -- sans que l'une n'écrase l'autre (même niveau de priorité).
      opts.sources = cmp.config.sources({
        { name = "copilot", priority = 1000 }, -- AI suggestions
        { name = "nvim_lsp", priority = 900 },  -- General coding
        { name = "omni", priority = 800 },      -- Houdini VEX & Others
        { name = "path", priority = 700 },      -- File paths
        { name = "buffer", priority = 500, keyword_length = 3 }, -- Current buffer
      })

      -- Ajout des icônes pour mieux distinguer la complétion IA des autres
      opts.formatting = opts.formatting or {}
      local original_format = opts.formatting.format
      opts.formatting.format = function(entry, vim_item)
        if entry.source.name == "copilot" then
          vim_item.kind = "🤖 Copilot"
          vim_item.kind_hl_group = "CmpItemKindCopilot"
        end
        if original_format then
          return original_format(entry, vim_item)
        end
        return vim_item
      end
    end,
  },
}
