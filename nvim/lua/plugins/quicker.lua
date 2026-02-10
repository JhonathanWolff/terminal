return
{
  'stevearc/quicker.nvim',
  ft = "qf",
  ---@module "quicker"
  ---@type quicker.SetupOptions
  opts = {},
  config = function ()
    local quicker = require("quicker")
    quicker.setup()
      
  end
}
