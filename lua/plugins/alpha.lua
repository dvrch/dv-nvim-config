return {
  "goolord/alpha-nvim",
  lazy = false, -- Force alpha-nvim to load on startup for debugging
  config = function()
    local alpha = require("alpha")
    local startify = require("alpha.themes.startify")
    alpha.setup(startify.config)
  end,
}