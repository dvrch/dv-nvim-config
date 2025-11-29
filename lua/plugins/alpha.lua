return {
  "goolord/alpha-nvim",
  lazy = false,
  priority = 1000,
  config = function()
    local alpha = require("alpha")
    local startify = require("alpha.themes.startify")
    alpha.setup(startify.config)
  end,
}