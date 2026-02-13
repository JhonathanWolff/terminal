return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		require("lualine").setup({
			sections = {
				lualine_c = {
					{
						"filename",
						path = 1, -- Caminho relativo (recomendado)
						file_status = true,
						shorting_target = 40,
					},
				},
			},
		})
	end,
}
