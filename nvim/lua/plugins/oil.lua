return {
	"stevearc/oil.nvim",
	config = function ()
		local oil = require("oil").setup({
			columns = { "icon" },
			keymaps = {
				  ["<C-p>"] = {"actions.preview",opts= {vertical = true, split = 'botright'}},
				   ["<BS>"] = { "actions.parent", mode = "n" },
			}
			

		})
	end
}
