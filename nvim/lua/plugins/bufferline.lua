return {
	"akinsho/bufferline.nvim",
	version = "*",
	dependencies = "nvim-tree/nvim-web-devicons",
	after = "catppuccin",
	  config = function()
	    require("bufferline").setup ({
		highlights = require("catppuccin.special.bufferline").get_theme()
	    })
	  end
}
