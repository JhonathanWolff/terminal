return {
	"nvim-treesitter/nvim-treesitter",
	lazy = false,
	build = ":TSUpdate",
	config = function()
		local treesiter = require("nvim-treesitter")
		treesiter.install({
			"html",
			"css",
			"go",
			"java",
			"python",
			"javascript",
			"json",
			"yaml",
			"bash",
			"zsh",
			"typescript",
			"vimdoc",
			"vim",
			"markdown",
			"latex"
		}) --:wait(300000)
		treesiter.setup()
	end,
}
