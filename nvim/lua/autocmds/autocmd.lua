

-- highlight yank
vim.api.nvim_create_autocmd("TextYankPost", {
	group = vim.api.nvim_create_augroup("highlight_yank", { clear = true }),
	pattern = "*",
	desc = "highlight selection on yank",
	callback = function()
		vim.highlight.on_yank({ timeout = 200, visual = true })
	end,
})

-- restore cursor to file position in previous editing session
vim.api.nvim_create_autocmd("BufReadPost", {
	callback = function(args)
		local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
		local line_count = vim.api.nvim_buf_line_count(args.buf)
		if mark[1] > 0 and mark[1] <= line_count then
			vim.api.nvim_win_set_cursor(0, mark)
			-- defer centering slightly so it's applied after render
			vim.schedule(function()
				vim.cmd("normal! zz")
			end)
		end
	end,
})

-- open help in vertical split
vim.api.nvim_create_autocmd("FileType", {
	pattern = "help",
	command = "wincmd L",
})


vim.api.nvim_create_autocmd("BufWritePre", {
  group = vim.api.nvim_create_augroup("trim_whitespace_group", { clear = true }),
  pattern = "*",
  command = [[%s/\s\+$//e]],
})

-- vim.api.nvim_create_autocmd("FileType", {
--   group = vim.api.nvim_create_augroup("EnableTreesitterHighlighting", { clear = true }),
--   desc = "Try to enable tree-sitter syntax highlighting",
--   pattern = "*", -- run on *all* filetypes
--   callback = function()
--     pcall(function() vim.treesitter.start() end)
--   end,
-- })
