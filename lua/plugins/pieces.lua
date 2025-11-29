return {
  dir = "/home/kd/.config/nvim/plugin_neovim", -- Path to your manually cloned plugin
  lazy = false,
  priority = 1000,
  config = function()
    package.path = package.path .. ";" .. "/home/kd/.config/nvim/plugin_neovim/lua/?.lua"
    require("pieces").setup({
      enable_cloud = true,
    })
  end,
}